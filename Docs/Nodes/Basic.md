# Принцип работы библиотеки

Принцип работы библиотеки построен на выстраиании цеопчки операций над данными. 

Каждая отдельная операция представлена узлом `Node<Input, Output>`.

`Input` - тип данных,которые узел получает. 

`Output` - тип данных, которые узел передает следующему узлу.

Каждый узел должен реализовывать метод `process(_ data: Input) -> Observer<Output>`

`Observer`-ы служат для связи узлув друг с другом. Такой подход позволяет реализовать что-то вроде акторной модели, к тому же каждый отдельный узел может исполнять операции в разных потоках.

Более подробно о них можно прочесть [тут](../Contexts.md)

Рассмотрим пример - с помощью созданной нами цепочки превратим строку, содержащий id сущности в объект с таким id.

```Swift

struct User {
    let id: String
    let name: String
    let photo: String
}

```

Это структура данных, которую мы хотим получить в итоге. 

Пусть у нас есть какая-то база данных, в которой лежит информация об этом пользователе.

Тогда, для того, чтобы получить его нам нужно написать в базу данных запрос. Сделаем это внутри узла. Это как раз подходящая операция.

Так как мы хотим получать пользователя по строковому `id`, то `Input == String`, а `Output == User`

```Swift

class UserReaderNode: Node<String, User> {

    let dbContext = DBContext.shared

    override func process(_ data: String) -> Observer<User> {

        let result = Context<User>()

        do {
            let user = try self.debContext.execute("SELECT user from user_table WHERE ID == \(data)") 
            result.emit(user)
        } catch {
            result.emit(error: error)
        }

        return result
    }
}

```

Пусть `dbContext` это объект подключения к асбтрактной `SQL` базе данных. 
Тогда реализация метода `process` следующая:
1. Создает результирующий контекст
2. Пытаемся выполнить запрос.
   1. Если запрос успешен - эмитим модель пользователя
   2. Если запрос неуспешен, то эмитим ошибку.

Теперь мы можем использовать это вот так:

```Swift

    func getUser(by id: String) -> Observer<User> {
        return UserReaderNode().process(id)
    }

```

Отлично! Теперь хочется мапить ошибки БД на какие-то собвтенные ошибки. Давайте напишем для этого узел.

```Swift

enum ReadError: Error {
    case notFound
    case cantConect
    case badRequest
    case undefind
}

class ErrorMapperNode: Node<String, User> {

    let next = UserReaderNode()

    override func process(_ data: String) -> Observer<User> {
        return self.next.process(data).map { error in
            switch (error as NSError)?.statusCode {
                case 100:
                    return ReadError.notFound
                case 101:
                    return ReadError.cantConect
                case 102:
                    return ReadError.badRequest
                default:
                    return ReadError.undefind
            }
        }
    }
}

```
Рассмотрим как это будет работать.

Сначала вызывается `ErrorMapperNode.prcoess()`. Внутри этого метода сразу же вызывается `UserReaderNode.process`. Затем, после того как этот метод отработал выполняется операция `map(_ (Error) -> Error)`. 

Отлично! Теперь, в случае если произойдет ошибка мы можем ее удобным способом обработать и точно показать нужную нам локализацию.
---
Вроде все просто и хорошо, однако хочется, чтобы запрос в БД исполнялся не на том потоке, из которого он был вызван. Давайте напишем для этого узел, который будет вызывать следующий узел на заданном нами потоке:

```Swift

class DispatcherNode: Node<String, User> {

    let queue: DispatchQueue

    let next = ErrorMapperNode()

    init(queue: DispatchQueue) {
        self.queue = queue
    }

    func process(_ data: String) -> Observer<User> {
        let result = Context<User>()

        self.queue.async {
            self.next.process(data)
                .onCompleted { model in
                    result.emit(model)
                }.onError { error in
                    result.emit(error: error)
                }
        }

        return result
    }
}

```

Здесь мы вызываем следующий узел на другом потоке, а затем ождиаем результатов его работы и эмитим их слушателю уже этого узла. Так как слушатель этого узла будет слушать `result`

Кстати реализовать это можно иначе:

```Swift

func process(_ data: String) -> Observer<User> {
   
    return .emit(data: data)
        .dispatch(on: self.queue)
        .map { self.next.process($0) }
}

```

Мы создаем контекст, эметим в него id, затем конвертиурем его в `AsyncContext` с нужной очередью, затем подключаем к полученному контексту результат следующего контекста. Для того, чтобы понять что здесь написано рекомендуется прочесть [статью про контексты](../Contexts.md)

Описание существующих узлов можно прочесть [тут](Existing.md)
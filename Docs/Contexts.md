# Контексты и наблюдатели

Одним из основных компонентов библиотеки является [Observer](https://lastsprint.dev/CoreNetKit/Docs/swift_output/Classes/Observer.html), а точнее [Context](https://lastsprint.dev/CoreNetKit/Docs/swift_output/Classes/Context.html) и его производные.

Они используются для того, чтобы наблюдать за запросом и в случае необходимости как-то его менять (например отменять).

Из-коробки Observer предоставляет три события:
1. `onCompleted` - вызывается в случае успешного завершения операции и пробрасывает результат
2. `onError` - вызывается в случае ошибки и пробрасывает ошибку
3. `onCancelled` - вызывается в случае, если операци была отменена
4. `defer` - вызывается в случае, если сработал 1 или 2, но не возвращает никаких данных

Реализация `Context` построена так, что после того, как событие произошло, то его рузльтат сохраняется внутри контекста, затем, в случае если подписчики уже есть, то они оповещаются о событии. В противном случае больше ничего не происходит.

Однако после появления подписчика, у него сразу же вызывается соответствующий метод (1 из перечисленных выше).

Например:

```Swift

var context = Observer.emit(data: "Word")
context.onCompleted { print("Hello \($0)!") }

```

Псоле испольнения этого кода будет выведено `Hello Word!`

То же справедливо для `onError`.

Но при этом, если написать такой код:

```Swift

var context = Observer.emit(data: "Word")
context.emit(error: Error.some)
context.onCompleted { print("Hello \($0)!") }
context.onError { _ in print("Error!") }

```

То будет выведено `Error!`

Но здесь

```Swift

var context = Observer<String>.emit(data: "Word")
context.emit(error: Error.some)
context.emit(data: "Word")
context.onCompleted { print("Hello \($0)!") }
context.onError { print("Error!") }

```
Снова будет выведено `Hello Word!`

То есть после появления взаимосисключающих событий предыдущие значение очищается. 
Так если была проброшена ошибка, а затем проброшен успешный ответ, то сообщение об ошибке затирается. 

## Операции

Все доступные операции перечислены [тут](https://lastsprint.dev/CoreNetKit/Docs/swift_output/Classes/Observer.html)

### error(_ mapper: @escaping (Error) throws -> Observer<Model>)

Задача этой операции сконвертировать ошибку в какой-то другой `Observer`. Например, таким образом можно "глушить" ошибки. 
Рассмотрим пример:

```Swift

let context = Context<String>()

context.error { error in
    if case Error.some = error {
        return .emit(data: "Word!")
    }

    return .emit(error: error)
}

context.onCompleted { print("Hello \($0)!") }
context.onError { _ in print("Error!") }

context.emit(error: Error.some)
context.emit(data: "Jack")
context.emit(error: Error.other)

```

То будет следующий вывод:

```
Hello Word!
Hello Jack!
Error!
```

Потому что когда мы заэмитили событие с Error.some то оператор `error`, получив управление, проверил, является ли ошибка `Error.some`, а так как она является, то мы вернули контекст с другим результатом.

Во втором случае управление даже не передалось оператору `error` так как ошибки не возникало. 

В третьем случае мы заэмитили другую ошибку, и оператор error не зашел в блок `if case` и просто пробросил ошибку дальше.

### map(_ mapper: @escaping(Error) -> Error)

Позволяет замапить одну ошибку в другую. Это как `map` для массивов. 

Удобно использовать если нужно замапить какю-то "коробочную" ошибку в кастомную.

### map<T>(_ mapper: @escaping (Model) throws -> T)

Полностью аналогично `map` для массивов.

### map<T>(_ mapper: @escaping (Model) -> Observer<T>)

Полностью аналогично `map` для массивов, только этот оператор позволяет замапить модель на новый контекст. 
Это может быть полезно в том случае, если необходимо выполнить последовательно несколько запросов, каждый из которых зависит от предыдущего. 
Рассмотрим пример:

```Swift

func getUsers(by id: String) -> Observer<[Users]> {

    return self.getShortAccount(by: id).map { data in
        return self.getUsers(by: data.usersFrameId)
    }
        
}

func getShortAccount(by id: String) -> Observer<AccountShort> { ... }

```

Здесь мы сначала получаем некоторые описания аккаунта, а затем по id из полученной модели запрашиваем набор пользователей, которые привязаны к этому аккаунту. 
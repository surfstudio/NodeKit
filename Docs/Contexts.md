# Содержание
- [Содержание](#%D1%81%D0%BE%D0%B4%D0%B5%D1%80%D0%B6%D0%B0%D0%BD%D0%B8%D0%B5)
- [Контексты и наблюдатели](#%D0%BA%D0%BE%D0%BD%D1%82%D0%B5%D0%BA%D1%81%D1%82%D1%8B-%D0%B8-%D0%BD%D0%B0%D0%B1%D0%BB%D1%8E%D0%B4%D0%B0%D1%82%D0%B5%D0%BB%D0%B8)
  - [Операции](#%D0%BE%D0%BF%D0%B5%D1%80%D0%B0%D1%86%D0%B8%D0%B8)
    - [error(_ mapper: @escaping (Error) throws -> Observer<Model>)](#error-mapper-escaping-error-throws---observermodel)
    - [map(_ mapper: @escaping(Error) -> Error)](#map-mapper-escapingerror---error)
    - [map<T>(_ mapper: @escaping (Model) throws -> T)](#mapt-mapper-escaping-model-throws---t)
    - [map<T>(_ mapper: @escaping (Model) -> Observer<T>)](#mapt-mapper-escaping-model---observert)
    - [combine<T>(_ provider: @escaping @autoclosure () -> Observer<T>) -> Observer<(Model, T)>](#combinet-provider-escaping-autoclosure----observert---observermodel-t)
    - [chain<T>(with contextProvider: @escaping (Model) -> Observer<T>?) -> Observer<(Model, T)>](#chaintwith-contextprovider-escaping-model---observert---observermodel-t)
    - [filter<T>(_ predicate: @escaping (T) -> Bool) where Model == [T]](#filtert-predicate-escaping-t---bool-where-model--t)
    - [dispatchOn(_ queue: DispatchQueue)](#dispatchon-queue-dispatchqueue)
    - [multicast()](#multicast)
    - [process(_ observer: (Observer) -> Void)](#process-observer-observer---void)


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

После испольнения этого кода будет выведено `Hello Word!`

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

То есть после появления взаимоисключающих событий предыдущие значение очищается. 
Так если была проброшена ошибка, а затем проброшен успешный ответ, то сообщение об ошибке затирается. 

Важно знать, что у контекста может быть только один слушатель (исключая `MulticastContext`).
Это означает, что вызов одного из 4х перечисленных выше методов перезаписывает слушателя. 
Поэтому, если вы попытаетесь пошарить один контекст на несколько классов, то вас ждет неудача (:

Эту проблему можно решить с помощью оператора `multicast`. 

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

Потому что когда мы заэмитили событие с `Error.some` то оператор `error`, получив управление, проверил, является ли ошибка `Error.some`, а так как она является, то мы вернули контекст с другим результатом.

Во втором случае управление даже не передалось оператору `error` так как ошибки не возникало. 

В третьем случае мы заэмитили другую ошибку, и оператор `error` не зашел в блок `if case` и просто пробросил ошибку дальше.

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

### combine<T>(_ provider: @escaping @autoclosure () -> Observer<T>) -> Observer<(Model, T)>

Комбинирует несколько наблюдателей. В качестве результата будет 1 `Observer` с двумя результатами. 

Может быть полезен в том случае, если необходимо исполнить два параллельных запроса. 

Пример:

Представим, что у нас есть экран, который состоит из 3х элементов:
1. Рекламные баннеры
2. Продукты (например это экран товаров в магазине)
3. Какие-то действия для ботомшита, например, запрос следующей партии товаров или что-то еще. Это действия, которые сервер может выполнять и они могут изменяться сервером в зависимости от каких-то причин.

Для того, чтобы собрать этот экран можно использовать оператор `combine`

```Swift

struct BuisnessValue {
    let banner: Banner
    let products: [Product]
    let actions: [Action]
} 

func getBuisnessValue() -> Observer<BuisnessValue> {
    return self.getBanner()
        .combine(self.getProducts)
        .combine(self.getActions)
        .map { (args) in
            let (banner, products, actions) = args
            return BuisnessValue(banner: banner, 
                                products: products, 
                                actions: actions)
        }
}

func getBanner() -> Observer<Banner> { }

func getProducts() -> Observer<[Product]> { }

func getActions() -> Observer<[Action]> { }

```

### chain<T>(with contextProvider: @escaping (Model) -> Observer<T>?) -> Observer<(Model, T)>

Этот оператор является почти суммой операторов `combine` и `map`. 
Он позволяет создать цепочку из наблюдателей, причем, каждый следующий наблюдатель создается из результата работы предыдущего, но в итоге работы всей цепочки будут результаты от каждого из наблюдателей.

Это может быть полезно в том случае, если необходимо выполнить несколько разных запросов, каждый из которых зависит от предыдущего, но в отличии от `map` нам нужны результаты каждого запроса.

Допустим, мы пишем банковское приложение и хотим получить описание счета, затем карты привязанные к этому счету, но при этом получить карты мы можем только узнав тип счета. В конечном итоге нам нужно вывести и описание счета и карты.

В таком случае реализовано это будет так:

```Swift

    func getAccount() -> Observer<Account> {
        return self.getShortAccount()
        .chain(self.getCards)
        .map { (args) in
            let (account, cards) = args
            return Account(short: account, cards: cards)
        }
    }

    func getShortAccount() -> Observer<ShortAccount> {

    }

    func getCards(model: AccountShort) -> Observer<[Card]> {

    }
```

### filter<T>(_ predicate: @escaping (T) -> Bool) where Model == [T]

Следует обратить внимание, что этот оператор может быть применен только к тем наблюдателям, у которых результат представлен массивом. 

Это просто обертка над операцией `filter` для коллекций. Может быть использован просто для удоства.

### dispatchOn(_ queue: DispatchQueue)

Конвертирует себя в [AsyncContext](https://lastsprint.dev/CoreNetKit/Docs/swift_output/Classes/AsyncContext.html)
и конфигурирует его переданной очередью. 
То есть после этого оператора ответ будет диспатчеризоваться на очереди `queue`

### multicast()

Конвертирует себя в [MulticastContext](https://lastsprint.dev/CoreNetKit/Docs/swift_output/Classes/MulticastContext.html)
После этого оператора у каждого контекста может быть несколько слушателей.

### process(_ observer: (Observer) -> Void)

Просто передает себя в замыкание. Может быть полезно для просмотра логов.
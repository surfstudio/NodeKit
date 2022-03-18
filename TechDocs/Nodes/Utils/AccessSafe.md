# Access Safe

Утилиты `AccessSafe` следует использовать если выполняются следующие условия:
1) Работа с сервером осуществялетя с помощью AccessToken'а
2) Сервер присылает RefreshToken - токен, с помощью которого можно обновить AccessToken, если последний "протух"
3) Есть метод для обновления AccessToken'a с помощью RefreshToken'a

## Принцип работы утилиты

1) Запросы уходят как обычно
2) Узел `AccessSafeNode` преобразует мапит ошибку ответа
3) Если ошибка не удовлетворяет условию, то она просто пробрасывается 
4) В случае, если ошибка `ResponseHttpErrorProcessorNodeError.forbidden || ResponseHttpErrorProcessorNodeError.unauthorized`, то запрос "Замораживается" в `TokenRefresherNode`
5) Каждый следующий запрос отправляется в `TokenRefresherNode`
6) `TokenRefresherNode` послыает запрос на обновление AccessToken'а 
7) Если токен обновился успешно, то `TokenRefresherNode` перезапускает каждый запрос.
8) Если во время обновлениятокена произошла ошибка, то она пробросится выше.

## Настройка

Сразу следует обратить внимание на то, что `AccessSafeNode` должен обязательно быть **ДО** узла, который добавляет AccessToken к запросу. В противном случае обновление токена не будет иметь эффект.

Инстанс `TokenRefresherNode` должен шариться между всеми экземплярами `AccessSafeNode`, иначе говоря `TokenRefresherNode` должен быть иснглтоном. Потому что в противном случае невозможно собратьв се запросы в одном месте. 

Так же `TokenRefresherNode` принимает цепочку, которая может послать запрос на обновление токена.
В этом случае можно написать сервис, который обычным образом отправляет нужный запрос, а затем этот сервис обернуть узлом и поставить в `TokenRefresherNode`

Затем уже необходимо поставлять `TokenRefresherNode` во все `AccessSafeNode`

## Пример

```Swift

class Service {
    func updateToken() -> Observer<Void> { ... }
}

class WrapperNode: Node<Void, Void> {
    override func process(_ data: Void) -> Observer<Void> {
        return Service().updateToken()
    }
}

class AccessSafeChainBuilder: UrlChainsBuilder {

    private static let tokenRefresherNode = TokenRefresherNode(tokenRefreshChain: WrapperNode())

    override func requestBuildingChain(with config: UrlChainConfigModel) ->  Node<Json, Json> {
        let transportChain = self.serviceChain.requestTrasportChain()

        // Добавили узел в цепочку
        let accessSafe = AccessSafeNode(next: transportChain, updateTokenChain: tokenRefresherNode)

        let urlRequestTrasformatorNode = UrlRequestTrasformatorNode(next: transportChain, method: config.method)
        let requstEncoderNode = RequstEncoderNode(next: urlRequestTrasformatorNode, encoding: config.encoding)
        let requestRouterNode = RequestRouterNode(next: requstEncoderNode, route: config.route)
        return MetadataConnectorNode(next: requestRouterNode, metadata: config.metadata)
    }
}
```

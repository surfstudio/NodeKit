# Узлы для интеграции с Mocker

Здесь содержится описание всех узлов, которые содержат логику для простоты интеграции с [Mocker](https://github.com/LastSprint/mocker#проксирование)

## MockerProxyConfigNode

Это узел, который умеет конфигурировать запрос так, чтобы включить функцию проксирования запроса у Mocker.
Узел встраивается между [MetadataConnectorNode](../Existing.md/#cборка-запроса) и [RequestRouterNode](../Existing.md/#cборка-запроса).

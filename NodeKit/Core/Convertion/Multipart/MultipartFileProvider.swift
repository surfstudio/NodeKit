import Foundation

/// Провайдер файлов для multipart-запросов.
///
///
/// - data: Поставляет файл как бинарные данные, включая имя и тип.
/// - url: Поставляет файл как путь до файла. В дальнейшем он будет загружен. Для запроса будут использованы оригинальные имя и тип.
/// - customWithUrl: Как и в `url` за тем исколючением, что имя файла и тип файла можно указать самостоятельно.
public enum MultipartFileProvider {
    case data(data: Data, filename: String, mimetype: String)
    case url(url: URL)
    case customWithUrl(url: URL, filename: String, mimetype: String)
}

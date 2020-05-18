//
//  ParametersEncoding.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 16/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Кодировка параметров запроса.
///
/// - json: Потыается закодировать данные в формате JSON и кладет их в тело запроса.
/// - jsonArray: Для кодировки массивов в Json. ИСпользуется если нужно получить Json вида `[ {}, {}, ...]`
/// - formUrl: Пытается закодировать данные в формате FormUrl и кладет из в тело запроса.
/// - urlQuery: Получает из данных строку,кодирует в URL-строку и добавляет к URL запроса.
public enum ParametersEncoding {
    case json
    case formUrl
    case urlQuery
}

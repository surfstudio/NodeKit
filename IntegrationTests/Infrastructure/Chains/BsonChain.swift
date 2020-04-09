//
//  BsonChain.swift
//  IntegrationTests
//
//  Created by Vladislav Krupenko on 03.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

@testable
import NodeKit

final class BsonChain: UrlBsonChainsBuilder<Routes> {

    override init(serviceChain: UrlServiceChainBuilder = CustomServiceChain()) {
        super.init(serviceChain: serviceChain)
    }

}

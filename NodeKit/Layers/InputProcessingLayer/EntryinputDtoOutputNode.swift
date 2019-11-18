import Foundation
import Combine

open class EntryinputDtoOutputNode<Input, Output>: Node<Input, Output>
                                                    where Input: RawEncodable, Output: DTODecodable {

    open var next: Node<Input.Raw, Output.DTO.Raw>

    init(next: Node<Input.Raw, Output.DTO.Raw>) {
        self.next = next
    }

    open override func process(_ data: Input) -> Observer<Output> {
        do {
            let raw = try data.toRaw()
            return self.next.process(raw).map { try Output.from(dto: Output.DTO.from(raw: $0) ) }
        } catch {
            return .emit(error: error)
        }
    }

    @available(iOS 13.0, *)
    open override func make(_ data: Input) -> PublisherContext<Output> {
        Just(data)
            .tryMap { try $0.toRaw() }
            .flatMap(self.next.make)
            .tryMap { try Output.from(dto: Output.DTO.from(raw: $0) ) }
            .asContext()
    }
}

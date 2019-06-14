import NodeKit
import PlaygroundSupport
import PDFKit

enum CustomError: Error {
    case badUrl
}

enum Endpoint {
    case loadPDF
}

extension URL {
    static func from(_ string: String) throws -> URL {
        guard let url = URL(string: string) else {
            throw CustomError.badUrl
        }
        return url
    }
}

extension Endpoint: UrlRouteProvider {
    func url() throws -> URL {
        switch self {
        case .loadPDF:
            return try .from("https://lastsprint.dev/t.pdf")
        }
    }
}

class ViewController : UIViewController {

    var pdfView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(pdfView)
        // Layout
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

    }
}

func loadPdf() -> Observer<Data> {
    let request = UrlChainConfigModel(method: .get, route: Endpoint.loadPDF)
    return UrlChainsBuilder().loadData(with: request).process()
}

loadPdf()
    .dispatchOn(.main)
    .onCompleted { data in
        let view = PDFView()
        let pdf = PDFDocument(data: data)
        view.document = pdf
        let vc = ViewController()
        vc.pdfView = view
        PlaygroundPage.current.liveView = vc
    }


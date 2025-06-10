import Foundation

struct ImageCellViewModel {
    let imageURL: URL?
    let isLiked: Bool
    let dateText: String
}

protocol ImageCellViewModelFactory {
    func makeViewModel(from photo: Photo) -> ImageCellViewModel
}

final class DefaultImageCellViewModelFactory: ImageCellViewModelFactory {
    private let isoDateFormatter: DateFormatting
    private let displayFormatter: DateFormatting
    
    init(
        isoDateFormatter: DateFormatting,
        displayFormatter: DateFormatting
    ) {
        self.isoDateFormatter = isoDateFormatter
        self.displayFormatter = displayFormatter
    }
    
    func makeViewModel(from photo: Photo) -> ImageCellViewModel {
        let dateText: String
        if let date = isoDateFormatter.date(from: photo.createdAt) {
            dateText = displayFormatter.string(from: date)
        } else {
            dateText = ""
        }
        
        return ImageCellViewModel(
            imageURL: URL(string: photo.thumbImageURL),
            isLiked: photo.isLiked,
            dateText: dateText
        )
    }
}


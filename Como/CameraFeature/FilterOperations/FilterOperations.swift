import GPUImage
import QuartzCore
//CISepiaTone
let filterNameList: Array<Filter> = [
    Filter(filterName: "Original", ciImageName: "", image: nil, tag:1),
    Filter(filterName: "Sepia", ciImageName: "CISepiaTone", image: nil, tag:2),
    Filter(filterName: "Chrome", ciImageName: "CIPhotoEffectChrome", image: nil, tag:3),
    Filter(filterName: "Fade", ciImageName: "CIPhotoEffectFade", image: nil, tag:4),
    Filter(filterName: "Instant", ciImageName: "CIPhotoEffectInstant", image: nil, tag:5),
    Filter(filterName: "Mono", ciImageName: "CIPhotoEffectMono", image: nil, tag:6),
    Filter(filterName: "Noir", ciImageName: "CIPhotoEffectNoir", image: nil, tag:7),
    Filter(filterName: "Process", ciImageName: "CIPhotoEffectProcess", image: nil, tag:8),
    Filter(filterName: "Tonal", ciImageName: "CIPhotoEffectTonal", image: nil, tag:9),
    Filter(filterName: "Transfer", ciImageName: "CIPhotoEffectTransfer", image: nil, tag:10),
]

let comoFilterOperations: Array<FilterOperationInterface> = [
    FilterOperation(
        filter:{OriginalFilter()},
        operation:OriginalFilter(),
        listName:"Original",
        titleName:"Original",
        sliderConfiguration:.Enabled(minimumValue:0.0, maximumValue:1.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.intensity = sliderValue
        },
        filterOperationType:.SingleInput
    ),
    FilterOperation(
        filter:{CyanGoldFilter()},
        operation:CyanGoldFilter(),
        listName:"CyanGold",
        titleName:"CyanGold",
        sliderConfiguration:.Enabled(minimumValue:0.0, maximumValue:1.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.intensity = sliderValue
        },
        filterOperationType:.SingleInput
    ),
    FilterOperation(
        filter:{LoverFilter()},
        operation:LoverFilter(),
        listName:"Lover",
        titleName:"Lover",
        sliderConfiguration:.Enabled(minimumValue:0.0, maximumValue:1.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.intensity = sliderValue
        },
        filterOperationType:.SingleInput
    ),
    FilterOperation(
        filter:{RetroASFilter()},
        operation:RetroASFilter(),
        listName:"RetroAS",
        titleName:"RetroAS",
        sliderConfiguration:.Enabled(minimumValue:0.0, maximumValue:1.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.intensity = sliderValue
        },
        filterOperationType:.SingleInput
    ),
    FilterOperation(
        filter:{SepiaGoldFilter()},
        operation:SepiaGoldFilter(),
        listName:"SepiaGold",
        titleName:"SepiaGold",
        sliderConfiguration:.Enabled(minimumValue:0.0, maximumValue:1.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.intensity = sliderValue
        },
        filterOperationType:.SingleInput
    ),
    FilterOperation(
        filter:{VictorianFilter()},
        operation:VictorianFilter(),
        listName:"Victorian",
        titleName:"Victorian",
        sliderConfiguration:.Enabled(minimumValue:0.0, maximumValue:1.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.intensity = sliderValue
        },
        filterOperationType:.SingleInput
    )
]
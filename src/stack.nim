var data*: seq[uint8]



proc push*(toPush: uint8, customPushIndex: int = -1)  =

    if customPushIndex == -1:
        data.add(toPush)
    else:
        data.insert(toPush, customPushIndex)


# customPopIndex is only used in PSIVAAPIUTVI
proc pop*(customPopIndex: int = -1): uint8 =
    
    let i = if customPopIndex == -1: len(data) - 1 else: customPopIndex

    result = data[i]
    data.del(i)
    
    return


proc reverseOrder*() =

    var newStackData: seq[uint8]

    while len(data) > 0:
        let i = len(data) - 1
        newStackData.add(data[i])
        data.del(i)
    
    data = newStackData
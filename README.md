# PFImagePickerController
***
* An easy way to fetch photos from photoLibrary and you can also use it to edit photos.

# Contents
***
## how to get started?
download the sourcecode.zip and uncompress it ,and then open the project, drag the folder PFImagePickerController to your project.

## usage
'  PFImagePickerController *imagePicekerController = [[PFImagePickerController alloc] init];
    imagePicekerController.delegate = self;
    imagePicekerController.maxNumber = 10;
    imagePicekerController.minNumber = 2;
    imagePicekerController.filter = PHAssetMediaTypeImage;
    [self presentViewController:imagePicekerController animated:YES completion:nil];
'
# summary
It provide you with an easy way to fetch photos from sy

# PFImagePickerController
***
* An easy way to fetch photos from photoLibrary and you can also use it to edit photos.

# Contents
***
## how to get started?
Download the sourcecode.zip and uncompress it ,and then open the project, drag the folder PFImagePickerController to your project.

## usage
'  PFImagePickerController *imagePicekerController = [[PFImagePickerController alloc] init];
    imagePicekerController.delegate = self;
    imagePicekerController.maxNumber = 10;
    imagePicekerController.minNumber = 2;
    imagePicekerController.filter = PHAssetMediaTypeImage;
    [self presentViewController:imagePicekerController animated:YES completion:nil];
'
# summary
It provide you with an easy way to fetch photos from system photolibrary. You can use it to multiSelect photos, edit photo(eg. rotate, clip, filter).If you have any problems during your development, send emails to me ,my email address is 2898889396@qq.com. Best wishes.

# Derotate
[Mobile app](https://drive.google.com/open?id=1UNQbxz8WtLMVVRjzhBN_1lzKLpgbJ504), [API](test_api.ipynb), and [Web App](http://54.145.131.146/), and  that understands if/how an image is rotated and "derotates" it. The app was built with [fastai v2 library](https://dev.fast.ai/) and the [fastai course](https://course.fast.ai/). Hopefully, this repo can also be useful for other people who wish to deploy fastai2 models, since it features:
* A back-end API that handles both image-to-class and image-to-image interfaces
* A [jupyter notebook](test_api.ipynb) that shows how to call the back-end APIs
* A mobile app (written in Flutter, which generates Android, iOS, and web apps from a single code base)
* And of course, the usual web-app that enables to upload an image and know how it was rotated (image-to-image are not supported yet, because of my lack of JS skills...)

## Demo
Here are some screenshots showing how the app works:

![img_input](https://github.com/sebderhy/derotate/blob/master/images/flutter1.jpg "flutter1") 
![img_input](https://github.com/sebderhy/derotate/blob/master/images/flutter2.jpg "flutter2") 
![img_input](https://github.com/sebderhy/derotate/blob/master/images/flutter3.jpg "flutter3") 
![img_input](https://github.com/sebderhy/derotate/blob/master/images/flutter5.jpg "flutter5") 

## Motivation
When I take pictures with my phone, the auto-rotate feature often doesn't work properly and my pictures end up having the bad orientation. This is of course an issue afterwards when looking at the pictures, but more importantly, the fact that different images can get different orientations is an important issue when building an automated image processing / computer vision pipelines. For example, if you use a phone as a dashcam, the images may have different orientation depending on how the user sets up his phone.

## How to use it?
The mobile and web apps are straightforward to use, and the python code snippet of API calls in the [test_api notebook](test_api.ipynb) should help you understand how to use it as an API. Again, this API can be used both as an Image-to-Class or as an Image-to-Image API.

## How does it work?
1) A Deep Neural Network classifier is trained to recognize if an image is rotated 90, 180, 270 or straight.
2) The image is then "derotated" using PIL library

## Model training

The Notebook responsible for model training is [training/isImgRotated-camvid-fastai2.ipynb](https://github.com/sebderhy/derotate/blob/master/training/isImgRotated-camvid-fastai2.ipynb)

In order to train the model, we download the [Camvid](http://mi.eng.cam.ac.uk/research/projects/VideoRec/CamVid/) dataset, rotate the images, and train a model (Resnet32) to recognize if & how an image is rotated.

## Deployment
The web API that does the inference is based on the starter pack [made by @muellerz](https://github.com/muellerzr/fastai2-Starlette), using Starlette.io framework with Uvicorn ASGI server.   

Everything is packaged in a docker with requirement.txt, so you can push it to any docker hosted cloud service. In my case, I originally used Google cloud, but since the cost was too high, I finally chose to use a simple server on AWS EC2, since I don't expect this app to be used at large-scale.

Enjoy and please let me know if you have any question or feedback!

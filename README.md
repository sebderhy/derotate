# Derotate
Web App & API that understands if/how an image is rotated and "derotates" it, built with [fastai v1 library](https://docs.fast.ai/) and using [fastai course](https://course.fast.ai/). It can be tested [here](https://derotate.appspot.com/)

## Motivation
When I take pictures with my phone, the auto-rotate feature often doesn't work properly and my pictures end up having the bad orientation. This is of course an issue afterwards when looking at the pictures, but more importantly, the fact that different images can get different orientations is an important issue when building an automated image processing / computer vision pipelines. For example, if you use a phone as a dashcam, the images may have different orientation depending on how the user sets up his phone.

## Example
For example, if you give the model the following image:
![img_input](https://github.com/sebderhy/derotate/blob/master/test_images/img_test_rotated270.jpg "Rotated image") 

Then the resulting image is:

![img_output](https://github.com/sebderhy/derotate/blob/master/test_images/img_test.jpg "Derotated image")

## How does it work?
1) A Deep Neural Network classifier is trained to recognize if an image is rotated 90, 180, 270 or straight.
2) The image is then "derotated" using PIL library

## Model training

The Notebook responsible for model training is [training/isImgRotated](https://github.com/sebderhy/derotate/blob/master/training/isImgRotated.ipynb)

In order to train the model, we download the [Imagenette](https://github.com/fastai/imagenette) dataset, rotate the images, and train a model (DenseNet121) to recognize if & how an image is rotated.

## Deployment
The web app that does the inference is based on the Google App Engine starter pack available [here](https://github.com/fastai/course-v3/raw/master/docs/production/google-app-engine.zip), using Starlette.io framework with Uvicorn ASGI server.

One notable difference compared to the starter web app is that this one also displays back the derotated model. The web app code could therefore be useful also for semantic segmentation, super-resolution, etc...   

Everything is packaged in a docker with requirement.txt, so you can push it to any docker hosted cloud service.

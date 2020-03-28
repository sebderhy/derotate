import aiohttp
from fastapi import FastAPI, File, UploadFile
import asyncio
import uvicorn
from fastai2.vision.all import *
from io import BytesIO
from starlette.applications import Starlette
from starlette.middleware.cors import CORSMiddleware
from starlette.responses import HTMLResponse, JSONResponse, FileResponse
from starlette.staticfiles import StaticFiles
import tempfile

export_file_url = '' ## TODO: Put model on GDrive and put the DL URL Here
export_file_name = 'models/is-img-rotated.pkl'

path = Path(__file__).parent

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=['*'], allow_headers=['X-Requested-With', 'Content-Type'])
app.mount('/static', StaticFiles(directory='app/static'))


async def download_file(url, dest):
    if dest.exists(): return
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            data = await response.read()
            with open(dest, 'wb') as f:
                f.write(data)


async def async_setup_learner():
    # await download_file(export_file_url, path / export_file_name)
    try:
        learn = torch.load(path/export_file_name, map_location=torch.device('cpu'))
        learn.dls.device = 'cpu'
        return learn
    except RuntimeError as e:
        if len(e.args) > 0 and 'CPU-only machine' in e.args[0]:
            print(e)
            message = "\n\nThis model was trained with an old version of fastai and will not work in a CPU environment.\n\nPlease update the fastai library in your training environment and export your model again.\n\nSee instructions for 'Returning to work' at https://course.fast.ai."
            raise RuntimeError(message)
        else:
            raise

loop = asyncio.get_event_loop()
tasks = [asyncio.ensure_future(async_setup_learner())]
learn = loop.run_until_complete(asyncio.gather(*tasks))[0]
loop.close()


@app.route('/')
async def homepage(request):
    html_file = path / 'view' / 'index.html'
    return HTMLResponse(html_file.open().read())


@app.get("/test_api/")
def test_api():
    return JSONResponse({
          'result': "It just works!"
    })


@app.post("/img2class/")
def img2class(file: UploadFile = File(...)):
    img_bytes = (file.file.read())
    pred = learn.predict(img_bytes)
    return JSONResponse({
          'result': str(pred[0])
    })


def image_to_byte_array(image:Image):
  imgByteArr = io.BytesIO()
  image.save(imgByteArr, format=image.format)
  imgByteArr = imgByteArr.getvalue()
  return imgByteArr


def derotate_img(pred, img_pil: Image):
    img_pil_out = img_pil
    rotation_state = str(pred[0])
    if(rotation_state=='rotated180'): img_pil_out = img_pil.rotate(180)
    if(rotation_state=='rotated90'): img_pil_out = img_pil.rotate(-90)
    if(rotation_state=='rotated270'): img_pil_out = img_pil.rotate(90)
    img_pil_out.format = img_pil.format
    return img_pil_out


@app.post("/img2img/")
def img2img(file: UploadFile = File(...)):
    img_bytes = (file.file.read())
    pred = learn.predict(img_bytes)
    img_pil = Image.open(BytesIO(img_bytes))
    img_pil_out = derotate_img(pred, img_pil)
    out_img_bytes = image_to_byte_array(img_pil_out)
    with tempfile.NamedTemporaryFile(mode="w+b", suffix=".png", delete=False) as FOUT:
        FOUT.write(out_img_bytes)
        return FileResponse(FOUT.name, media_type="image/png")


if __name__ == '__main__':
    if 'serve' in sys.argv:
        uvicorn.run(app=app, host='0.0.0.0', port=80, log_level="info")
        

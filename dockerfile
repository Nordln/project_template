# Container for building the environment from https://uwekorn.com/2021/03/01/deploying-conda-environments-in-docker-how-to-do-it-right.html
# conda-lock -f predict-environment.yml -p linux-64 -k explicit --filename-template "predict-{platform}.lock"
# build with: docker buildx build -t nyc-taxi-distroless-buildkit-expert --load -f Dockerfile .
# rub with: docker run -ti -p 8000:8000 nyc-taxi-distroless-buildkit-expert

FROM condaforge/mambaforge:4.9.2-5 as conda

COPY predict-linux-64.lock .
RUN --mount=type=cache,target=/opt/conda/pkgs mamba create --copy -p /env --file predict-linux-64.lock && echo 4
COPY . /pkg
RUN conda run -p /env python -m pip install --no-deps /pkg

# Distroless for execution
FROM gcr.io/distroless/base-debian10

COPY --from=conda /env /env
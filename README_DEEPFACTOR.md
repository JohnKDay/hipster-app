## Deepfactor Easy Instrumentation

Latest compliled non-deepfactor images can be found in:  
`docker.io/johnkday`
All images are tagged `nodf-latest`

To deploy a non-DF instrumented deployment just run

`kubectl apply -f hipster-app_nodf.yaml`

To instrument the DF, download (from `TERMINAL` button)  
and replace the Dockerfile.glibc.df
and Dockerfile.alpine.df from your DeepFactor Portal into this directory.

Run the script to instrument and push images to your repository.  
`./DFinstrument.sh [source registry] [target registry]`

This will create instrumented images with tags `df-latest`
and then you will need to manually modify the  
`hipster-app_df.yaml` to change the image repository location,  
then run `kubectl apply -f hipster-app_df.yaml`

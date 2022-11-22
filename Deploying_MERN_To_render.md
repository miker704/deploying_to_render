# Deploying MERN Stack Projects from Heroku.com to Render.com

- These instructions are for deploying a MERN Project from Heroku.com to Render.com
- It assumes you have made all the steps needed to deploy successfully to Heroku.com
- This method works for cohorts 3/2022 - 8/2022
- This guide is used to push a MERN project using JWT tokens if your using CSRF-Tokens use the instructions for deployment on App Academy Open, if they fail to work keep the changes involving CSRF-Tokens and redact everything else and this guide should work for you.

If your cohort started after 9/2022 its recommended you follow the instructions on App Academy Open first before trying this method,
if that method fails you'll need to combine Open's instructions and the instructions here to deploy your application.

## If your looking to deploy your rails-react app click here [Rails-React_DEPLOY](./README.md)

## Disclaimers Before Proceeding

- If your app has code that is dependent on the full url including the domain/host name to execute/ generate some data link custom urls, invite links etc. You will need to make the proper changes after obtaining your website url from render.com.

    Example of apps dependent on domain urls  

```.js
        //code to generate access to a picture 

        let newPicture = `appname.herokuapp.com/#/${this.props.newPicture.id}`

        //or some invite url for a chat app clone (discord/slack/zoom etc)

        let newInviteLink = `appname.herokuapp.com/#/${this.props.server.id}/${this.props.server.mainChannelId}`
```  

- If you want to maintain your heroku deployment and have a render deployment as well AND your code is dependent on the url of your domain/host name
either right a conditional check to handle mutliple platforms or create seperate repos for sepreate deployments and provide all live links to the orignal repos readme.md.

Lets go over quickly on a condtional check for using a singler repo for multiple platform deployment  

- You must have seperate repos of your application for deployments on aws, heroku or render specifically, you can deploy to all these platforms using one repo if you can write a condtional check for the url for example

```.js

      let heroku_url = `appname.herokuapp.com/#/`;
      let render_url = `appname.onrender.com/#/`;

      let platform_url = this.props.location.pathname = something
      // NOOOOO !!!! this does not work props,history and props.location only returns script paths

      // we will have to use js windows api util library 


      //example running on local host current url is
      // 'http://localhost:3000/#/@me/:serverid/:channelId'
      
      // returns current path like props.location.pathname does
      
      windows.location.pathname = '/@me/:serverid/:channelId'

      //returns the host name (domain name)
      
      
      windows.location.hostname = localhost

      //full url in the search bar

      //local host example

      windows.location.href = 'http://localhost:3000/#/@me/:serverid/:channelId'

      //heroku example and render example

      windows.location.href = 'http://appname.herokuapp.com/#/@me/:serverid/:channelId'

      windows.location.href = 'http://appname.onrender.com/#/@me/:serverid/:channelId'

        
      //if the only platforms are heroku and render that the app is deployed on 
      //if you have more platforms use a switch statement to handle the check

      let platform_url = window.location.href.includes(heroku_url) ? heroku_url : render_url   
```

If this seems much or you have alot of files that use the the full url we can deploy seperate repos for each platform:  

To do this we must create seperate repos here you'll something new about git

We will mirror repos of our project:

- On your github or git lab account create a new repo named your app name _ platform example : appname_render or appname_heroku in the console navigate to whereever your projects are stored and create a new directory

    ```shell script
      user:~/.../ mkdir appname_render
      user:~/.../ cd appname_render
      user:~/.../ git clone --bare https://github.com/user/old-repository-appname.git (your orignal repo link)
      user:~/.../ cd old-repository-appname.git
      user:~/.../ git push --mirror https:://github.com/user/new-repository.git    (the new repo you created moments ago)
      user:~/.../ cd ..
      user:~/.../ rm -rf old-repository-appname.git  //delete git of old repo
      user:~/.../ git clone https:://github.com/user/new-repository.git  //clone the mirrored repo
      user:~/.../ cd appname_platformname

    ```

You dont have to do these steps if:

- You are abandoning heroku to move to render
- your app's code is not dependent on using your domain name for some task
- If your app is domain dependent but your are not deploying to both heroku and render you can make the changes for render and push to the orginal repo.

## Code Prep

- Your app should be already cleaned up if you deployed to heroku already if not do so remove console.logs, debug statements, disable redux logging etc.
- run npm install for both your front and backends to make sure your app builds and works properly.
- update any existing npm packages with security issues with:  

```shell
npm audit // view what needs to update
npm audit fix // update whatever can be changed safely
npm audit fix --force // force the update (including breaking changes avoid this unless you know what your doing)
```

Now here comes the confusing part every person has their own custom build scripts in there ```package.json``` files however we typically follow
a similar format/ the scripts are generally the same, only the commands maybe named differently.

For package.json at the root directory

```json
"scripts": {
    "server:debug": "nodemon --inspect app.js",
    "server": "nodemon app.js",
    "start": "node app.js",
    "frontend-install": "npm install --prefix frontend",
    "frontend": "npm start --prefix frontend",
    "dev": "concurrently \"npm run server\" \"npm run frontend\"",
    "heroku-postbuild": "NPM_CONFIG_PRODUCTION=false npm install --prefix frontend && npm run build --prefix frontend"
  },

```

For package.json in frontend/package.json

```json
 "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
```

In your app.js file in the root directory should have a line looking like this:

```.js
if (process.env.NODE_ENV === 'production') {
  app.use(express.static('frontend/build'));
  app.use(cors());

  app.get('/', (req, res) => {
    res.sendFile(path.resolve(__dirname, 'frontend', 'build', 'index.html'));
  })
}

```

If you have deployed this app to heroku before your app is basically ready to deploy to render. using the heroku-postbuild script to build the
static frontend files into a frontend/build folder via express was needed to deploy to heroku we can use this same script and code on render.com. If you havent deployed to heroku before its reccommended to use the tutorial on App Academy Open first.

If your using CSRF-TOKENS in your app.js file refer to the instructions on app academy open first, if your app fails to deploy using Open's instructions remove the changes made keeping only the changes needed in app.js for CSRF-Tokens and continue with this guide.

Now prior to pushing your changes to github/gitlab if your mern project was built on machines using different operating systems, windows/wsl, mac os or linux you may experience a build error on render for unsupported platform given. To avoid this delete all  ```package-lock.json``` files leaving only the ```package.json``` files then push to github/gitlab.

## Render.com

- The steps for Render.com are the same on App Academy open built we'll go over them quickly.

1). Go to <https://render.com/> sign up with your git account (you should be using github) or sign in.

2). Grant permissions for render to access your account and repo's.

### Redis (If your App uses Web Sockets)

1). Create a Redis Instance by click New +  and selecting Redis

- Create your Redis Instance provide a name (preferably in lowercase chars and the same as your app name)
- Select region if your in new york  -> Ohio(US East), California -> Oregon (US West)
- Leave everything else blank/ to their default values
- Make sure the free tier is selected
- Click Create Redis

#### Web Service

1). In seperate tabs navigate to the dashboard and in the other Create a Web Service by clicking New + and Selecting Web Service

2). You will be redirected to a page asking to connected a repository on the right side click on configure on either your  github or gitlab account to grant render access to the repos in your account. After this a list of all your repo's should be listed, select the repo of the app you want to deploy by clicking connect.

- Provide the name of your app (keep it lowercase to avoid problems)

- Leave Root directory blank (your main branch serves as this already)

- Environment Render might auto detect Node and select it for you, if not make sure it is selected

- Select region if your in new york  -> Ohio(US East), California -> Oregon (US West)

- Branch select the main option

- For build command replace the string provided with npm install && npm run heroku-postbuild

- Start Command Replace the string with npm run start && npm run frontend

- Leave everything else blank/ to their default values

- Make sure the free tier is selected

- Click advanced

- Click Add Environment Variables

  - If you are using websockets In the other tab go to the render dashboard click on the redis instances and
    click on the connect button and copy the url that is provided by the internal connection slide
    this url is the value to are environment vars

  - Enter Key value pairs

```{
    Key                              Value
    MONGO_URI                        Your Mongo db url that should be in your key_dev.js file (dont wrap url in " ")
    SECRET_OR_KEY                    whatever secretOrKey is in your key_dev.js file (do not wrap the key in " ")
    REDIS_URL                        redis internal connection url (if using redis)
```

- List any other key:value pairs your app needs for production deployment (I.e API Tokens, google maps api, google auth, twillo, etc)

- Click disable automatic deployment (Auto deploy rebuilds and re-deploys your site after every git push although convenient its more of a nuisance and is best to leave it disabled).

- Click Create Web Service your website will start to build from here if auto deploy was selected it will start building automatically. If auto-deploy is not enabled click on manual deploy and select "Clear build cache & deploy". The build process takes anywhere up to 20 mins to finish.

- If your using Redis a link to your website is provided copy this and head back to your project and make the need changes for your web sockets to work on render.com. Push to github after making the changes and rebuild on render via  "Clear build cache & deploy".

Thats it Your Done!

## Errors and Troubleshooting

1). My app was build and deployed but the webpage only renders the line "Error not Found!" and/or the render build console gives an error comprising of  

"Nodejs: Error: ENOENT: no such file or directory"

In your environement variable make sure your MONGO_URI && SECRET_OR_KEY are not wrapped in quotes.
Your build script did not build your frontend components of your application.

Try the App Academy Open method below

you can proceed to change your script blocks in your root package.json and frontend.json to do the following

## App Academy Open Method

root package.json

```json
  "scripts": {
    "backend-install": "npm install --prefix backend",
    "backend": "npm run dev --prefix backend",
    "frontend-install": "npm install --prefix frontend",
    "frontend": "npm start --prefix frontend",
    "frontend-build": "npm run build --prefix frontend",
    "build": "npm run backend-install && npm run frontend-install && npm run frontend-build"
  },
 ```

frontend package.json

```json
"scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
```

After changing this run:

```shell
    npm run build  //run npm install for root and frontend and builds to frontend/build folder
    npm start --prefix backend
```

The server for the backend should be running and the your app should be working in the browser
delete your package-lock.json files in the root and frontend directories, .gitignore or delete the frontend/build folder and push to github and then on render.com change your build script
to npm run build and your start script npm start --prefix backend then click manual deploy and select "Clear build cache & deploy".

2). I tried both methods yours and App Academy's and they both did not work

I tried App Academy`s method and it yielded some problems so I figured out another way to get my mern app working:

First ensure your root package.json script block has something similar to this:

```json
"scripts": {
    "server:debug": "nodemon --inspect app.js",
    "server": "nodemon app.js",
    "start": "node app.js",
    "frontend-install": "npm install --prefix frontend",
    "frontend": "npm start --prefix frontend",
    "dev": "concurrently \"npm run server\" \"npm run frontend\"",
    "heroku-postbuild": "NPM_CONFIG_PRODUCTION=false npm install --prefix frontend && npm run build --prefix frontend"
    
  },

```

And your frontend package.json has a script body like:

```json
 "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
```

 In the shell folder of this repo there is a shell script file titled ```render_my_MERN.sh```  create a new shell file in your projects root directory titled ```render-build.sh``` copy the code contained in ```render_my_MERN.sh``` to your shell file.

The script in ```render_my_MERN.sh```

```shell
#!/usr/bin/env bash
# exit on error
set -o errexit

npm install
npm install --prefix frontend
npm run build --prefix frontend

```

Push your repo back to github/gitlab and head back to render.com go to your dashboard click on the web service (your mern app) you are deploying go to settings and change the following by clicking the edit button

build command to ```./render-build.sh```.  

Start Command to ```npm run start```

click save changes then click manual deploy and select "Clear build cache & deploy".

3). npm install error (code EBADPLATFORM) or npm error unsupported platform for fsEvents  
This error gives some additionl; information comprising of:  

```shell

  os: darwin, arch: x64
  basically some operating system specs

```

The cause of this error is due to the project being developed on multiple machines involving different operating systems i.e direct development on windows os, wsl, linux, and mac os, or any of the previously mentioned on virtual machine platform like virtualbox.

To fix this go to your project and delete the package-lock.json files in your frontend and root directories and make sure the .gitignore files
in both root and frontend ignore node_modules folders. the package-lock.json files in the node_modules folder in either directory can also trigger this
error as well so make sure they are untracked. Push the changes to github/gitlab and then head back to render.com and rebuild your application.

# Deploying a Rails-React Full-Stack Application to Render.com (Heroku -> Render only)

## For Deploying MERN Projects to Render.com from Heroku those instructions are here [MERN_DEPLOY](./Deploying_MERN_To_render.md)

- These set of instructions are dedicated to App Academy students proceeding to re-deploy their rails - react full-stack apps from Heroku.com to Render.com, and the provided instructions on App Academy open have failed to work for them.

- Note to clarify these set of instructions is using the latest version of rails and ruby as of 11/18/22
Rails version 7.0.4 & Ruby version 3.1.2, if these instructions fail to work it maybe due to your project using rails 5.2.8/5.2.8.1 and ruby 2.5.1. A seperate version of instructions will be provided to address this version.

- Again, these instructions are for those that have already deployed to Heroku.com and have failed to re-deploy to Render.com using the instructions App Academy open. This assumes that your repo is already cleaned and prepared for deploying to Herkou in the first place.

- This tutorial uses a combination of both App Academy`s instruction along with instructions provided via the rails app deployment docs on Render.com.

- This tutorial also covers steps for Applications that use Action Cable as well and the adjustments needed to be made to be used on Render.com.

### Final Disclaimer

- Deploying you app on render.com can be tedious and build times are pretty long for free tier users. around 20 minutes once your build starts.
- Unlike like Heroku an app that is deployed on render has a feature for auto deployment while this feature
seems useful, it only leads to frustration a single push to github regardless of the change can cause a build to fail. DISABLE AUTO-DEPLOY !
- When working on an app deployed to render the changes in the config/puma.rb needed for the push must be commented out everytime you work on your app, as the code in this file will affect how data and your page re-renders especially if using Action Cable.

### Steps

#### Code Base Prep

***

1). If you attempted to deploy to render.com using the App Academy Open instructions, proceed to redact all new changes made for render deployment. Note if your application uses the url of the platform your using to
create or execute some functionality for example generating a url for an invitation to a chat room or access some data.

Example:

```.js
//code to generate access to a picture 

let newPicture = `appname.herokuapp.com/#/${this.props.newPicture.id}`

//or some invite url for a chat app clone (discord/slack/zoom etc)

let newInviteLink = `appname.herokuapp.com/#/${this.props.server.id}/${this.props.server.mainChannelId}`

```

Any code like this will need to be changed in order to work on render however you wont be able to make these changes till our website url is set up once we are able to obtain a link to our new website url change any code that is dependent on the platform url you are using. You can write a condtion check to handle different domain names check Dual Deploy section at the bottom of the readme.md

IMPORTANT!: If you have a project that you want to be deployed on both render and heroku but uses code that is dependent on the deployed platform url to function, like the code given above Check the Important notes and troubleshooting section for the listing 'Dual Deploying an App that is dependent on platform urls' at the bottom of this repo for full instructions, complete this before proceeding as the changes that need to be made will break the live version on heroku or render once a rebuild on either platform is initiated. If your app does not depend on its platform url to function you can disregard this and can deploy to both sites safely. If you are abandoning heroku and moving to render you will have to make the code changes needed in your app after obtaining your website url.

2). run bundle install and npm install to ensure your packages are up to date.

- If you recently upgraded your rails and ruby versions of your project rails 6.X.X or 7.X.X and your project uses active storage run (this step maybe done already if you have been working on your project since upgrading)

```bat
rails active_storage:update
rails db:migrate
rails db:drop
rails db:setup
```

Check to see if the updated migration files for active storage are up to date both rails 6.X.X and 7.X.X each have new migration files for active storage. Ensure after running rails db:setup that the seeding of your database is successful. Run your application as you normally would to verify that any pre-seed active storage media is present in your application.

3). In the bin folder of your rails app create a new .sh file named :

```render-build.sh```

- This repo provides both script versions for ease of use, check shell file folder you can copy the file
as your shell script make sure the shell file is named ```render-build.sh```

***
Rails Version 5.2.X (this is the minimum to get your app running note that these instructions may fail)

For rails version 5.2.X proceed with the following script first if the build fails on render.com use
the rails version 7 script

```bat
#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate

#if site renders but no seeded data is present add this line 

rails db:seed #if needed, comment this line out whenever pushing to a working deployment to avoid db errors

```

If you attempted to set up a web service before on render most of these commands are the default given to you. this script is the minimum needed to deploy on render however if it fails to deploy proceed with the script below which should work for all versions of rails

***
Rails Version 6.X.X or 7.X.X onwards

```bat
#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
npm install
npm run build
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate
rails db:seed #if needed, comment this line out whenever pushing to a working deployment to avoid db errors

```

The difference between these scripts is that some students have been able to deploy their app using just the provided build script given by render without seeding, while others have to provide the seed command. And in my case using the default commands only renders the rails root page if this is the case the rails 6.X.X -> script works. Its likely if your app uses rails 5.2.8 you may be fine just using the default build commands provided by render.com.

4). Change production code in config/database.yml

Go to config/database.yml in your project go to production version of your database connectivity

Orginal

```.rb
#
production:
  <<: *default
  database: appname_production
  username: appname
  password: <%= ENV['appname_DATABASE_PASSWORD'] %>

```

Change to this :

```.rb
#
production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>

  # database: appname_production
  # username: appname
  # password: <%= ENV['APPNAME_DATABASE_PASSWORD'] %>

```

Note indention matters in .yaml files !  

Do not remove the old data base connection code incase you need to deploy to a different platform in the future, you may need to use the old code instead.

5). Change code in config/puma.rb

- These changes are part of the instruction set given by Render

Original

```.rb
# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
# preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

```

Change to :

```.rb
# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#


 workers ENV.fetch("WEB_CONCURRENCY") { 4 }



# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#


 preload_app!



# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

```

Here we uncomment and increase the web worker from 2 to 4 unlike heroku render allows concurrency usage for free.

we also uncomment preload_app! which allows some assets to be loaded by puma before executing the application and allows the web workers to use less memory.

### Important Note

When working on your app comment these lines out for ```preload_app! and the code for webworkers``` your app is very unlikely to be be built with concurrency programming to begin with. Your app will fail to receive changes rendered on screen. This frequently occurs when sending and receiving data using action cable the web workers will take the request but fail to return data that would be rendered on screen as the main thread will finish its process before the worker thread can. Uncomment these lines before pushing to render again.

6). Production file changes in config.environments/production.rb

Around lines 20-30 this line of code should be present

```.rb
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
```

Copy and paste this line underneath it and add the extra condition next to it,
comment out the original version of this line.

```.rb
  #config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present? || ENV['RENDER'].present?
```

If you are moving your project from heroku you should have this line already if not add it

```.rb

  config.assets.js_compressor = Uglifier.new(harmony: true)

```

7). Now if your app does not use anything special like action cable we are basically done here.

Do the following to ensure one last time everything is rebuilt and works smoothly:

```bat

bundle exec rails db:drop 
bundle install && npm install
bundle exec rails db:setup

rails s

```

In a seperate console run

```bat

npm run start #or whatever prefix you set for webpack

```

If everything works push everything to github and proceed to render.com to setup our site from there.
If you are using action cable unfortunately we will have to return to our project later to make adjustments.

#### Render.com Prep

- The steps for Render.com are the same on App Academy open built we'll go over them quickly.

1). Go to <https://render.com/> sign up with your git account (you should be using github) or sign in.

2). Grant permissions for render to access your account and repo's.

***

#### Database Prep

1). Since our rails-react apps are using Postgresql proceed to the dashboard and Click the big blue button
titled New + and click on PostgreSQL (note that every 90 days your db will be dropped, so every 85 days disconnect your db, delete it and connect your app with a new one)

- Create your db provide both name and user (keep them the same and in lowercase chars)
- Select region if your in new york  -> Ohio(US East), California -> Oregon (US West)
- Leave everything else blank/ to their default values
- Make sure the free tier is selected
- Click Create Database

Note whenever we create a database wait at least 2-5 minutes before connecting your app to it to prevent build errors.

Since you can only have one PostgreSQL DB instance active on render you must share it with any other apps you deploy on Render.com that uses Postgres for steps on how to do that please use the App Academy Open instructions.

***

#### Redis (If your App uses Action Cable / Web Sockets)

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

- Environment Render might auto detect Node and select it for you change it to Ruby

- Select region if your in new york  -> Ohio(US East), California -> Oregon (US West)

- Branch select the main option

- For build command replace the string provided with ```bin/render-build.sh```

- Start Command Replace the string with ```rails s```

- Leave everything else blank/ to their default values

- Make sure the free tier is selected

- Click advanced

- Click Add Environment Variables

  - In the other tab that is at the dashboard click on postgresql and redis instances and
      click on the connect button and copy the url that is provided by the internal connection slide
      this url is the value to are environment vars

    - Enter Key value pairs

```{
  Key                              Value
  DATABASE_URL                     postgresql internal connection url
  RAILS_MASTER_KEY                 whatever your key is in your master.key file
  REDIS_URL                        redis internal connection url (if using redis)
```

- List any other key:value pairs your app needs for production deployment (I.e API Tokens, google maps api, google auth, twillo, etc)

- Click disable automatic deployment if you use action cable to avoid having to drop your db and      connecting a new one. (Auto deploy rebuilds and re-deploys your site after every git push although convenient its more of a nuisance and is best to leave it disabled).

- Click Create Web Service your website will start to build from here if auto deploy was selected it will start building automatically. If auto-deploy is not enabled click on manual deploy and select "Clear build cache & deploy". The build process takes anywhere up to 20 mins to finish.
  
- For Redis Users a link to your website is provided copy this and head back to your project

#### For Redis users

1). Go to application.html.erb remove old meta property tags for heroku if they exist.
    add the two lines

```.rb
    <%= action_cable_meta_tag %> 
    <meta property="og:url" content="https://appname.onrender.com/#/" />
```

2). Navigate to your config/production.rb file and remove the old websocket urls for heroku if they exist then add the following

```.rb
  config.action_cable.url = 'wss://appname.onrender.com/cable'
  config.web_socket_server_url = 'wss://appname.onrender.com/cable'
  config.action_cable.allowed_request_origins = ['http://appname.onrender.com', 'https://appname.onrender.com']
```

3). Now there are two ways to create an action cable instance and use it in your app for any cable created in your react front end using

```.js
    App.cable_name = App.cable.subscriptions.create({channel: 'channel_name', id: channel_id},{...})
```

you dont have to do any changes for cables created using this method here, but if you create a cable by invoking a consumer instance and binding it to ```subscriptions.create()``` like so:

```.js
    const cable = createConsumer('ws://localhost:3000/cable'); // if using local host

    //or if using heroku

    const cable = createConsumer('wss://appname.herokuapp.com/cable');
    
    this.subscription = cable.subscriptions.create({channel:'channel_name', id: channel.id},{...})

```

This type of cable creation needs to be changed. Change all instances of this cable creation to use
the url of your render website like so  

```.js
    
    //const cable = createConsumer('ws://localhost:3000/cable'); 

    // keep local host url when working on project comment it out when pushing to render
    // create a consumer instance using your render website url / cable

    const cable = createConsumer('wss://appname.onrender.com/cable');

    //comment out the render url instance when working on your project and use local host
    //push to github only the render url instance uncommented so it works on render


    this.subscription = cable.subscriptions.create({channel:'channel_name', id: channel.id},{...})

```

Sync these changes to github and head back to render.com

- We are almost done go the the dashboard click on your web service we created and click on the blue button
title manual deploy and select clear build cache & deploy. your website will now build it should take no more than 20 minutes to finish.

Note: if you want to you can enable Auto-Deploy by click settings and heading to Auto-Deploy click edit and set it to true and save changes.

Thats it your done!

***

### IMPORTANT NOTES && TROUBLESHOOTING

### My App was deployed but renders the root page from rails

Using render-build.sh rails version 5.X.X script -> Rails Root page renders only

1). If you used the rails 5.X.X script to deploy on render.com your app may deploy but it may render only
the root page from your rails backend (as if your react frontend breaks) if this is the case use the rails 6.X.X - 7.X.X script instead.

2). If your app renders to your splash or login page using the 5.X.X script but you cant sign in with your demo account/ missing pre-seeded assets add ```rails db:seed``` at the end of the shell file. note that some apps using rails 5.X.X work fine without this command being provided.

3). For every build fail that requires a reseed you should delete the data base, create and connect a new one after the changes to your code has been pushed to github and a re-build/ deploy on render has been started.

### My data does not render when working on my project

4). When working on your application disable the webworkers and preload! code in config/puma.rb
by commenting them out and uncommenting them before pushing back to render, your app is not configured
for concurrency programming and can prevent receiving certain data requests. This is noticeable if your
app uses Action Cable sending messages does not render on either users screen instantly due to the web workers taking the request, handling it but fails to send it back to either user this is due to the main thread of the application finishing its process before the web worker can. Applications take the main thread process as priority over web workers/ sub threads.

### My app successfully deployed but however when I pushed a new change it failed to build

5). This can be due to anything on your end, but its likely your db was re-seeded with data that cant be
duplicated. To address issues with this its best to disable auto-deployment and create a new postgres db instance to connect to your app and rebuild it when big changes are made to your application. Do not waste your time rebuilding your app for every little change disable auto deploy to prevent breakages on your live version.

### I get an Error about Webpack CLI

6). Use the build script for rails 6+ even if your using rails 5 you need to run npm install during the
build process on render.

## Dual Deploy an Application (Keeping Heroku version up and deploying to Render)

- Dual Deploying an Application can fall under to different situations that need to addressed differently:

  - If you have an application that does not use code that depends on your deployed platform url to generate some data (i.e. urls, invites, etc) or execute some task you can deploy the application on both render and heroku keeping both versions live without any problems.

  - If you have code that is DEPENDENT on your platforms url to generate data (i.e. urls, invites, etc)/ execute tasks you will need to do the following:

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

user:~/.../ git push --mirror https:://github.com/user/new-repository.git (the new repo you created)

user:~/.../ cd ..

user:~/.../ rm -rf old-repository-appname.git //delete git of old repo

user:~/.../ git clone https:://github.com/user/new-repository.git //clone the mirrored repo

user:~/.../ cd appname_platformname

```

  After this process proceed to make needed changes to your project after you obtain your new domain url
  on render.com use connect to this repo to deploy this version of your app
  after successful deployment you can choose to keep this repo private and provide the url for render.com in the readme.md file
  of the original repo along with the heroku version.

### Why mirror? and not fork or clone ?

  This is simply due to that cloning the project means any pushed changes affect the orignal repo (if your authorized to make changes)

  Forked repos are basically copies of the orignal repo when changes are pushed to the parent repo the fork can be used to sync those
  changes to the forked version undoing any changes you may have pushed to your fork. You can use a fork as a seperate repo and make changes without affecting the parent repo, but the fact that your fork changes can be overwritten by an accidental sync, makes a fork repo too volatile to use for deployment to a different platform. This is especailly true for a project with multiple collaborators. However you can use a fork to deploy to another platform just be aware of the steps needed :

- use git stash to save Platform dependent code needed to deploy to an alt-platform
- sync with the upstream repo (parent repo)
- git pop to restore the code stored in your stash
- make the necessary integrations needed for you app to work with the newly synced changes from upstream
- push to github/gitlab
- rebuild your app on the other hosting platforms you are deploying on.

  If you are using gitKraken this process will be much more conflict free and easier to avoid merge conflicts and accidental overwrites.

  Mirrored repos are copies of the original repo including commit history, with exceptions to wiki and other repo props
  and can be pushed changes to itself that do not reflect to the original nor can changes in the orignal repo affect the mirrored. Its also an easier way to create a new repo for an existing project than removing the old git folder and creating a new one it allows you access to the projects git history to make and undo changes easily.

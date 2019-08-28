# spacecommander

An app to get control over the free space in a large NAS environment. 
Spacecommander enables you to see free space, provisioned space, and 
over/under provisioning in an environment with multiple locations and 
NAS servers.

## Features

* Roll up your NASes by location, enabling a summary view of all space available
* Graphs by [Chartkick](https://www.chartkick.com/) provide quick summations and visual representation of space used.
* Physical and logical views allow you to compare actual disk to disk logically provisioned.
* API calls to NASes are cached for 12 hours, preventing unnecessary strain on NAS servers.
* Supports NetApp NAS environments through the [NetApp Manageability SDK](https://community.netapp.com/t5/Software-Development-Kit-SDK-and-API-Discussions/NetApp-Manageability-NM-SDK-5-4-Introduction-and-Download-Information/td-p/108181) and the OnTap API.
* FreeNas support is currently being worked on and will be available in a later version.

## Requirements

Spacecommander requires the following:

* A ruby environment
  - This app has been tested with ruby 2.6.3 and uses rails 5.1.7.  Other versions of ruby may work also; but, I have not tested them.
  - I recommend using [rbenv](https://github.com/rbenv/rbenv) to set up your ruby environment.  The `.ruby-version` file included in this project should automatically set the tested version of ruby, if it is installed.
* The [NetApp Manageability SDK](https://community.netapp.com/t5/Software-Development-Kit-SDK-and-API-Discussions/NetApp-Manageability-NM-SDK-5-4-Introduction-and-Download-Information/td-p/108181)
  - This is required if you're using NetApp NASes.
  - The ruby files in the SDK provide the underlying client to the OnTap API used to gather data on NetApp controllers.

## Getting Started

To get started, clone this repository onto your server. 

Once you have the code on your server, you will be doing the following:

* Configuring your ruby environment
* Downloading the NetApp Managebility SDK and placing the ruby classes in the proper lib folder
* Configuring your NAS access via `config/nas.yml`
* Installing the bundle
* Testing your setup
* (Optional) Configuring your Apache server to serve spacecommander

### Configuring Your Ruby Environment

This application has been tested against ruby 2.6.3.  You will need a ruby
environment installed to run this application, preferably against the tested 
version.  If you don't already have one, I can recommend using [rbenv](https://github.com/rbenv/rbenv)
to set one up (follow the instructions on the rbenv github page).

### Downloading and Installing the NetApp Manageability SDK Ruby Files

Since the NetApp SDK is not open source, I cannot distribute it with this application.
If you are connecting to NetApp servers, you will need to download the SDK and
place the ruby files in the proper folder.  Follow the below steps to make the NetApp
ruby sdk files available to the application.

1. Register for an account at https://mysupport.netapp.com if you don't already have one.
1. Once you're logged in, go to the software download page (http://mysupport.netapp.com/NOW/cgi-bin/software).
1. Find "NetApp Manageability SDK" in the list.  In the drop down next to it, select "All Platforms" and click the "Go!" button.
1. On the next page, select the latest version of the SDK and click the "View and Download" button.
1. At the bottom of the information page under "Software Download Instructions," click the "Continue" link.
1. On the EULA page, click the "Accept" button at the bottom of the page.
1. On the resulting page, click the download link under the "Download Instructions" heading. This should (finally!) download a zip file.
1. Extract the contents of the zip, which should all be in a single folder.
1. Inside the extracted folder, copy the contents of the `lib/ruby/NetApp` folder to `lib/netapp_sdk` in your cloned copy of this project.  The files should be:
  * `DfmErrno.rb`
  * `NaElement.rb`
  * `NaErrno.rb`
  * `NaServer.rb`

### Configuring Your NetApp Access

You need to have a valid configuration in `config/nas.yml`.  To get started,
copy `config/nas_default.yml`.  If you don't want to configure your NAS
API access before testing your environment, you can stop there.  If you want to
configure your NASes now, take a look at `config/nas_example.yml`.  You'll 
have to configure NetApp cluster vifs under the `clusters` hash in the YAML file and
any NetApp storage virtual servers under the `vservers` hash key in each cluster.  For
NetApp 7-mode servers, you can add them to to the `sevenmode_nodes` hash key.  The NetApp
api users should have read-only (at least) access to the `ontapi` application.

For every NAS endpoint (cluster, vserver and 7-mode controller), you can also add a location
string.  All matching locations will be grouped together and summed in the 
location pages.

### Installing the Bundle

Once you have your ruby environment sorted out and have a sane netapp.yml config, 
navigate to the source directory and run `bundle install`.  This should install 
all the necessary gems to run this application.  If any gem installations fail, 
it might be related to packages that also need to be installed.  Pay attention to 
the error output to see what might be missing.

### Testing Your Setup

You can test your setup using the rails server. Navigate to the folder of your 
copy of the code and type `bundle exec rails server`.  You should see output similar
to this:

```
=> Booting Puma
=> Rails 5.1.3 application starting in development on http://localhost:3000
=> Run `rails server -h` for more startup options
Puma starting in single mode...
* Version 3.9.1 (ruby 2.2.2-p95), codename: Private Caller
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://0.0.0.0:3000
Use Ctrl-C to stop
```

Now, in a browser, you can navigate to your app by going to:
`http://<your server name or ip>:3000`.  You should see the "All Locations" page
if everything worked properly.  

If you see a "connection refused" message, your firewall might be blocking port 3000.  Make certain that the firewall is configured to allow tcp connections to 3000 and try again.

### Configuring Apache for Spacecommander

You can optionally configure apache for spacecommander using `mod_passenger`.
If you're going to share spacecommander in an environment with multiple users,
this is highly recommended.  Building and installing passenger is beyond the 
scope of this readme; but, your vhost should include these directives:

```
RackEnv production
RailsEnv Production
DocumentRoot /path/to/project/public
```

## License

Copyright 2019 Aaron M. Bond

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Additional Open Source Licenses

Chartkick is provided under the MIT License.  See the `chartkick_LICENSE` file for more information.


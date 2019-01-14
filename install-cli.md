# Command Line Interface

We'll interface with OpenShift and Kubeflow mostly via the browser and a command line interface in the terminal.

## Openshift CLI

OpenShift ships with a feature rich web console as well as command line
tools to provide users with a nice interface to work with applications
deployed to the platform. The OpenShift tools are a single executable
written in the Go programming language and is available for the
following operating systems:

  - Microsoft Windows

  - macOS 10

  - Linux

You might already have the OpenShift CLI available on your environment.
You can verify it by running an `oc` command:

```
$ oc version
```

You should see the following (or something similar):

```
{{OC_VERSION}}
```

If the `oc` doesn’t exist or you have an older version of the OpenShift
CLI, follow the next sections to install or update the OpenShift CLI.
Otherwise, skip to the next lab.

### Download the CLI

Download the the OpenShift CLI tool for your OS from [{{DOWNLOAD_CLIENT}}]({{DOWNLOAD_CLIENT}})


#### Install OpenShift CLI on Linux

Once the file has been downloaded, you will need to extract the contents
as it is a compressed archive. I would suggest saving this file to the
following directories:

```
~/openShift
```

Open up a terminal window and change to the directory where you
downloaded the file. Once you are in the directory, enter in the
following command:

> **Caution**
> 
> The name of the oc packaged archive may vary. Adjust accordingly.

```
$ tar zxvf oc-linux.tar.gz
```

The tar.gz file name needs to be replaced by the entire name that was
downloaded in the previous step.

Now you can add the OpenShift CLI tools to your PATH.

```
$ export PATH=$PATH:~/openShift
```

At this point, we should have the oc tool available for use. Let’s test
this out by printing the version of the oc command:

```
$ oc version
```

You should see the following (or something similar):

```
{{OC_VERSION}}
```

If you get an error message, you have not updated your path correctly.
If you need help, raise your hand and the instructor will assist.

#### Install OpenShift CLI on Mac

Once the file has been downloaded, you will need to extract the contents
as it is a compressed archive. I would suggest saving this file to the
following directories:

```
~/openShift
```

Open up a terminal window and change to the directory where you
downloaded the file. Once you are in the directory, enter in the
following command:

> **Caution**
> 
> The name of the oc packaged archive may vary. Adjust accordingly.

```
$ tar zxvf oc-macosx.tar.gz
```

The tar.gz file name needs to be replaced by the entire name that was
downloaded in the previous step.

Now you can add the OpenShift CLI tools to your PATH.

```
$ export PATH=$PATH:~/openShift
```

At this point, we should have the oc tool available for use. Let’s test
this out by printing the version of the oc command:

```
$ oc version
```

You should see the following (or something similar):

```
{{OC_VERSION}}
```

If you get an error message, you have not updated your path correctly.
If you need help, raise your hand and the instructor will assist.

#### Install OpenShift CLI on Windows

Once the file has been downloaded, you will need to extract the contents
as it is a compressed archive. I would suggest saving this file to the
following directories:

```
C:\OpenShift
```

In order to extract a zip archive on windows, you will need a zip
utility installed on your system. With newer versions of windows
(greater than XP), this is provided by the operating system. Just right
click on the downloaded file using file explorer and select to extract
the contents.

Now you can add the OpenShift CLI tools to your PATH. Because changing
your PATH on windows varies by version of the operating system, we will
not list each operating system here. However, the general workflow is
right click on your computer name inside of the file explorer. Select
Advanced system settings. I guess changing your PATH is considered an
advanced task? :) Click on the advanced tab, and then finally click on
Environment variables. Once the new dialog opens, select the Path
variable and add **`;C:\OpenShift`** at the end. For an easy way out,
you could always just copy it to C:\\Windows or a directory you know is
already on your path. For more detailed instructions:

  - [Windows XP](https://support.microsoft.com/en-us/kb/310519)

  - [Windows Vista](http://banagale.com/changing-your-system-path-in-windows-vista.htm)

  - [Windows 7](http://geekswithblogs.net/renso/archive/2009/10/21/how-to-set-the-windows-path-in-windows-7.aspx)
  
  - [Windows 8](http://www.itechtics.com/customize-windows-environment-variables/)

  - Windows 10 - Follow the directions above.

At this point, we should have the oc tool available for use. Let’s test
this out by printing the version of the oc command:

```
> oc version
```

You should see the following (or something similar):

```
{{OC_VERSION}}
```

If you get an error message, you have not updated your path correctly.
If you need help, raise your hand and the instructor will assist.

## Clone the workshop

Head over to {{WORKSHOP_BASE_URL}} and either fork the repository to your github account and then clone the repo to your local machine.

```
git clone https://github.com/durandom/openshift_kubeflow_workshop.git
```

In case you don't have `git` installed, you can also download the workshop [as a zip]({{WORKSHOP_BASE_URL}}/archive/master.zip)

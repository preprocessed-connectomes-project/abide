---
layout: page
title: abide-AWS
---

This serves as a guide to:

1. Launch an AWS-hosted AMI with C-PAC installed and functioning
2. Download FCP-INDI data from an AWS-hosted S3 bucket to use as input data for processing

# 1: Launch the CPAC AMI

## Log in to EC2
1. Go to [http://aws.amazon.com/console/](http://aws.amazon.com/console/)
2. Click the `Sign in to the AWS Console` button.
3. Enter in your AWS user email address and password and click `Sign in using our secure server.`
4. Here is the AWS console, with all the various tools Amazon offers for utilizing their web services.

## Get our AMI
5. Click on the `EC2` icon. EC2 is Amazon's cloud computing service which allows you to launch, connect to, and use virtual computing environments, called instances.
6. Amazon has different regions that it hosts its web services from, e.g. Oregon, Northern Virginia, Tokyo, etc. In the upper right-hand corner there will be a region that you're logged into next to your user name. Change this to N. Virginia. * Note if you're not in the N. Virginia region, you will not find our AMI.
7. In the left-hand column under the `INSTANCES` header, click `Instances`. This is a dashboard of all instances you currently have running on the cloud in AWS. Click the blue `Launch Instance` button.
8. On the left-hand side of the new page, click on the `Community AMIs` tab and search `cpac` in the search text box.
9. The `CPAC-OHBM-Hackathon-2014` AMI should appear. Hit `Select`.

## Configure your Instance

### Hardware specs and details
* This next page is where you choose the hardware specifications for your instance. Typically, for CPAC to run effectively, at least 16GB of RAM is optimal. The m3.xlarge instance type has 15GB of RAM and 4 CPUs and functions well with CPAC. To select this type, click on the `General purpose` tab and select the `m3.xlarge` size instance. Next, click `Next: Configure Instance Details`.
* This page can be used to launch multiple instances from this AMI, or request Spot instances as well as other things. For now, we don't need to do anything here, but it can be customized if desired. Next, click `Next: Add Storage.`

### Storage
* Here we can change how much storage is allocated for the instance being launched. By default, it is set to 30GB. Next, click `Next: Tag Instance`.
* This next page we can tag the instance to give it a name as a reminder for why we launched it. Something like `CPAC-Demo` works. Click `Next: Configure Security Group`.

### Security
* Here is where we can modify who has access to this instance; if you'd like to customize security and user access to the AMI, it can be done here.
* The default launch-wizard security group allows access for all IP addresses. If this is acceptable, Click `Review and Launch.`
* If you'd like to be the only computer to have ssh access to the instance, you can add/change a rule for the security group that only allows a certain range of IP addresses. Change the `Type` drop down menu to `SSH` and the `Source` drop down to `My IP`; AWS will automatically read your IP address range and set the field value accordingly.

### Launch
10. This final page summarizes the instance details you are about to launch. Look over everything to check your configuration
11. Click the `Launch` button. 

### Key-pair setup
12. A dialogue box opens asking about choosing a key pair for the instance. Every instance requires a key pair in order to securely login and use it. If you haven't created a key pair yet, change the top drop down menu to `Create a new key pair.` Then name the key pair something like `user-cpacdemo-northva`. Click `Download Key Pair` and save it to your machine.
13. Change the top drop down menu bar to `Choose an existing key pair` and select the name of the key pair you just downloaded in the bottom drop down menu. Check the acknowledgement check box and launch the instance.
14. Click the `View Instances` blue button on the lower right of the page after to watch the instance start up.

## Using your instance
15. Once it is up and running, it will display `2/2 checks passed` under the `Status checks` column. 
16. You can now ssh into the instance and use it. Click on the instance and copy the string of the instance's `Public DNS`
20. Open a terminal and type `ssh -i {path/to/keypair.pem} -X ubuntu@{public-dns-of-instance-amazonaws.com}`
21. It will start the connection and ask if you trust the source; type `yes`.
22. You should now be in the instance! There should be cpac related files in `/home/ubuntu/`. Feel free to launch `cpac_gui` and have at it!

# 2: Download the ABIDE Preprocessed data from an Amazon S3 bucket

1. A template python script to perform the download of the preprocessed data from the FCP-INDI S3 bucket is available on [our Github repo](https://raw.githubusercontent.com/preprocessed-connectomes-project/abide/master/get_s3_paths.py) via `wget`.
2. Within the script, the `csv_path` string specifies the path to the phenotypic data csv file of the ABIDE preprocessed data. This file is downloadable from the [FCP-INDI bucket](https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Phenotypic_V1_0b_preprocessed.csv) via `wget`.
3. Within the script, the `download_root` string specifies the path to the base directory for storing all of the downloaded data. Change this to suit your needs.
4. Within the script, under line 27, is an if statement which pulls data from S3 based on subject phenotypic data. By default, the script pulls down all subjects who's data came from 'CALTECH', who were male, and over the age of 30. But these conditions can be customized to pull down any desired data.
5. Within the script, under line 35, are the `pipeline`, `strategy`, and `derivative` values. These specify the pipeline, strategy, and derivative, from which, the data was processed. By default, the script looks for the results of a CPAC-processed, globally-filtered strategy used to generate the degree-centrality derivatives.
6. Executing the script via `python get_s3_paths` will begin the download of the files to the `download_root` directory. Enjoy!


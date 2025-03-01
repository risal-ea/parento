/*
SQLyog Community v13.1.6 (64 bit)
MySQL - 5.7.9 : Database - parento
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`parento` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `parento`;

/*Table structure for table `adminssion_request` */

DROP TABLE IF EXISTS `adminssion_request`;

CREATE TABLE `adminssion_request` (
  `adminssion_id` int(100) NOT NULL AUTO_INCREMENT,
  `parent_id` int(100) DEFAULT NULL,
  `baby_id` int(100) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `preferred_schedule` varchar(100) DEFAULT NULL,
  `qr_code` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`adminssion_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

/*Data for the table `adminssion_request` */

/*Table structure for table `admission_payment` */

DROP TABLE IF EXISTS `admission_payment`;

CREATE TABLE `admission_payment` (
  `payment_id` int(100) NOT NULL AUTO_INCREMENT,
  `admission_id` int(100) DEFAULT NULL,
  `amount` varchar(100) DEFAULT NULL,
  `date_time` datetime DEFAULT NULL,
  `status` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`payment_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

/*Data for the table `admission_payment` */

/*Table structure for table `babies` */

DROP TABLE IF EXISTS `babies`;

CREATE TABLE `babies` (
  `baby_id` int(100) NOT NULL AUTO_INCREMENT,
  `parent_id` int(100) DEFAULT NULL,
  `baby_name` varchar(100) DEFAULT NULL,
  `baby_dob` varchar(100) DEFAULT NULL,
  `baby_gender` varchar(100) DEFAULT NULL,
  `baby_photo` varchar(100) DEFAULT NULL,
  `allergies_or_dietry_restriction` varchar(100) DEFAULT NULL,
  `medical_condition` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`baby_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

/*Data for the table `babies` */

/*Table structure for table `chat` */

DROP TABLE IF EXISTS `chat`;

CREATE TABLE `chat` (
  `chat_id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_id` int(11) DEFAULT NULL,
  `sender_type` varchar(100) DEFAULT NULL,
  `receiver_type` varchar(100) DEFAULT NULL,
  `message` varchar(1000) DEFAULT NULL,
  `date_time` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`chat_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

/*Data for the table `chat` */

/*Table structure for table `checking_history` */

DROP TABLE IF EXISTS `checking_history`;

CREATE TABLE `checking_history` (
  `check_id` int(11) NOT NULL AUTO_INCREMENT,
  `admission_id` int(11) DEFAULT NULL,
  `check_in_date` varchar(100) DEFAULT NULL,
  `check_in_time` varchar(100) DEFAULT NULL,
  `check_out_date` varchar(100) DEFAULT NULL,
  `check_out_time` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`check_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

/*Data for the table `checking_history` */

/*Table structure for table `complaint` */

DROP TABLE IF EXISTS `complaint`;

CREATE TABLE `complaint` (
  `complaint_id` int(100) NOT NULL AUTO_INCREMENT,
  `login_id` int(100) DEFAULT NULL,
  `complaint` varchar(100) DEFAULT NULL,
  `reply` varchar(100) DEFAULT NULL,
  `date_time` datetime DEFAULT NULL,
  `status` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`complaint_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

/*Data for the table `complaint` */

/*Table structure for table `daily_activity` */

DROP TABLE IF EXISTS `daily_activity`;

CREATE TABLE `daily_activity` (
  `activity_id` int(11) NOT NULL AUTO_INCREMENT,
  `baby_id` int(11) DEFAULT NULL,
  `date` varchar(100) DEFAULT NULL,
  `activity_type` varchar(100) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `start_time` varchar(100) DEFAULT NULL,
  `end_time` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`activity_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

/*Data for the table `daily_activity` */

/*Table structure for table `day_care` */

DROP TABLE IF EXISTS `day_care`;

CREATE TABLE `day_care` (
  `day_care_id` int(100) NOT NULL AUTO_INCREMENT,
  `login_id` int(100) DEFAULT NULL,
  `day_care_name` varchar(100) DEFAULT NULL,
  `owner_name` varchar(100) DEFAULT NULL,
  `phone` varchar(100) DEFAULT NULL,
  `adress` varchar(100) DEFAULT NULL,
  `license_number` varchar(100) DEFAULT NULL,
  `capacity` varchar(100) DEFAULT NULL,
  `operating_time` varchar(100) DEFAULT NULL,
  `daycare_discription` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`day_care_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

/*Data for the table `day_care` */

insert  into `day_care`(`day_care_id`,`login_id`,`day_care_name`,`owner_name`,`phone`,`adress`,`license_number`,`capacity`,`operating_time`,`daycare_discription`) values 
(1,2,'baby care','ibru','2435436754','mullakkal(H)','lc65435654','40','7:00','super'),
(2,4,'sula house','salah','5647365879','abc','l475647','35','7:40','wow');

/*Table structure for table `facilities` */

DROP TABLE IF EXISTS `facilities`;

CREATE TABLE `facilities` (
  `facility_id` int(100) NOT NULL AUTO_INCREMENT,
  `day_care_id` int(100) DEFAULT NULL,
  `facility_name` varchar(100) DEFAULT NULL,
  `facility_type` varchar(100) DEFAULT NULL,
  `facility_des` varchar(100) DEFAULT NULL,
  `facility_capacity` varchar(100) DEFAULT NULL,
  `facility_image` varchar(100) DEFAULT NULL,
  `operating_hrs` varchar(100) DEFAULT NULL,
  `safety_measures` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`facility_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

/*Data for the table `facilities` */

/*Table structure for table `feedback` */

DROP TABLE IF EXISTS `feedback`;

CREATE TABLE `feedback` (
  `feedback_id` int(100) NOT NULL AUTO_INCREMENT,
  `day_care_id` int(100) DEFAULT NULL,
  `login_id` int(100) DEFAULT NULL,
  `feedback` varchar(100) DEFAULT NULL,
  `date_time` datetime DEFAULT NULL,
  PRIMARY KEY (`feedback_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

/*Data for the table `feedback` */

/*Table structure for table `login` */

DROP TABLE IF EXISTS `login`;

CREATE TABLE `login` (
  `login_id` int(100) NOT NULL AUTO_INCREMENT,
  `username` varchar(100) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL,
  `usertype` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`login_id`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

/*Data for the table `login` */

insert  into `login`(`login_id`,`username`,`password`,`usertype`) values 
(1,'admin','admin','admin'),
(2,'babycare','psw','dayCare'),
(7,'rashad','rashad','parent'),
(4,'sula','sula','dayCare');

/*Table structure for table `parent` */

DROP TABLE IF EXISTS `parent`;

CREATE TABLE `parent` (
  `parent_id` int(100) NOT NULL AUTO_INCREMENT,
  `login_id` int(100) DEFAULT NULL,
  `parent_name` varchar(100) DEFAULT NULL,
  `parent_email` varchar(100) DEFAULT NULL,
  `parent_phone` varchar(100) DEFAULT NULL,
  `parent_adress` varchar(100) DEFAULT NULL,
  `parent_dob` varchar(100) DEFAULT NULL,
  `parent_gender` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`parent_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

/*Data for the table `parent` */

insert  into `parent`(`parent_id`,`login_id`,`parent_name`,`parent_email`,`parent_phone`,`parent_adress`,`parent_dob`,`parent_gender`) values 
(1,6,'rashad','rashad@gmail.com','5647568976','abc','3/4/2004','male'),
(2,7,'rashad','rashad@gmail.com','5647568976','abc','3/4/2004','male');

/*Table structure for table `staff` */

DROP TABLE IF EXISTS `staff`;

CREATE TABLE `staff` (
  `staff_id` int(100) NOT NULL AUTO_INCREMENT,
  `login_id` int(100) DEFAULT NULL,
  `day_care_id` int(100) DEFAULT NULL,
  `staff_name` varchar(100) DEFAULT NULL,
  `staff_email` varchar(100) DEFAULT NULL,
  `staff_phone` varchar(100) DEFAULT NULL,
  `staff_dob` varchar(100) DEFAULT NULL,
  `gender` varchar(100) DEFAULT NULL,
  `staff_adress` varchar(100) DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `qualification` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`staff_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


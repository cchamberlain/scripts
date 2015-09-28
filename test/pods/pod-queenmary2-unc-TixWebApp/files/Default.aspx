<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="Default" ClientIDMode="Static" %>

<script runat="server">
/*
 * CHANGE LOG
 * ggb: 05/07/2015 - Initial Creation
 * REE 5/18/15 - Changed links to production URLs.   Added Google Tracking Code.
 * REE 5/19/15 - Enhanced Google Tracking.
 * REE 5/22/15 - Changed Ticket Buyer Login link to Account.asp.
 * REE 5/22/15 - Added Google Tracking to Info Request submission button.
 * REE 5/26/15 - Changed Ticket Buyer Login link to Login.aspx.
 * REE 5/26/15 - Removed PageView page version.
 * REE 6/13/15 - Added 'Free Demo' buttons and form. Removed Jumbotron animation.  Rearranged content. Made Search less prevalent.  Changed 'Login' to 'Tix Client Login' and made is less prevalent.  Added Page Title tracking for Google Analytics.
 * REE 6/19/15 - Added Tix Blog to navigation.
 * REE 6/29/15 - Changed external reference to Sweet-Alert to local.
 * REE 7/17/15 - Luke modified the file to fix various issues including issues with display on small screens.
 * REE 7/17/15 - Modified the file to remove the Management login at the top and fix the ID reference on the Search button.
 * REE 7/21/15 - Changed CustomB.css to Custom.css in order to migrate this page from Defaultb.aspx to Default.aspx (A/B Test migration).
 * REE 7/21/15 - Added phone number to Info Request form.  Text change on Jumbotron (Removed "Tix is a" before "state of the art..." and the word "system"). Changed "Tix sales representative" to "we".
 * REE 8/04/15 - Added Capterra tracking.
 * LSP 8/20/15 - added <meta http-equiv="X-UA-Compatible" content="IE=EDGE" /> to fix issue with comp mode in IE
 * LSP 8/27/15 - Added customer service e-mail to footer
 * REE 9/11/15 - Changed Nav Free Demo button to Get Started.  Added Customer service links on Info Request form with Google Analytics tracking.
*/
</script>

<!DOCTYPE html>
<!--[if IE 9]> <html lang="en" class="ie9"> <![endif]-->
<!--[if IE 8]> <html lang="en" class="ie8"> <![endif]-->
<!--[if !IE]><!-->
<html lang="en">
<!--<![endif]-->
<meta http-equiv="X-UA-Compatible" content="IE=EDGE" />

<head runat="server">
	<meta charset="utf-8">
	<title>Tix - Software and services for online and box office ticket sales</title>
	<meta name="description" content="Ticketing solutions for box office software, online ticket sales and ticketing services." />
	<meta name="keywords" content="ticketing solutions, box office software, online ticket sales, ticket software, Tix, ticket service, internet ticket sales,  box office system" />

	<!-- Mobile Meta -->
	<meta name="viewport" content="width=device-width, initial-scale=1.0">

	<!-- Favicon -->
	<link rel="SHORTCUT ICON" href="/Images/FavIcon.ico" />

	<!-- Jquery and Bootstap core js files -->
	<script type="text/javascript" src="/Clients/TixNew/plugins/jquery.min.js"></script>
	<script type="text/javascript" src="Clients/TixNew/js/angular.min.js"></script>
	<script type="text/javascript" src="/Clients/TixNew/bootstrap/js/bootstrap.min.js"></script>

	<!-- Web Fonts -->
	<link href="//fonts.googleapis.com/css?family=Open+Sans:400italic,700italic,400,700,300&amp;subset=latin,latin-ext" rel="stylesheet" type="text/css">
	<link href="//fonts.googleapis.com/css?family=PT+Serif" rel="stylesheet" type="text/css">

	<!-- Icon Font -->
	<link href="/Clients/TixNew/fonts/font-awesome/css/font-awesome.css" rel="stylesheet">

	<!-- Event Icon Font -->
	<link href="/Clients/TixNew/fonts/event-icons/css/event-icons.css" rel="stylesheet">

	<!-- Bootstrap core CSS -->
	<link href="/Clients/TixNew/bootstrap/css/bootstrap.css" rel="stylesheet">

	<!-- Plugins -->
	<link href="/Clients/TixNew/plugins/rs-plugin/css/settings.css" media="screen" rel="stylesheet">
	<link href="/Clients/TixNew/plugins/rs-plugin/css/extralayers.css" media="screen" rel="stylesheet">
	<link href="/Clients/TixNew/plugins/magnific-popup/magnific-popup.css" rel="stylesheet">
	<link href="/Clients/TixNew/css/animations.css" rel="stylesheet">
	<link href="/Clients/TixNew/plugins/owl-carousel/owl.carousel.css" rel="stylesheet">
	<link href="/Clients/TixNew/bootstrap/css/bootstrap-sweetalert.css" rel="stylesheet" type="text/css">

	<!-- iDea core CSS file -->
	<link href="/Clients/TixNew/css/style.css" rel="stylesheet">

	<!-- Color Scheme (In order to change the color scheme, replace the red.css with the color scheme that you prefer)-->
	<link href="/Clients/TixNew/css/skins/gold.css" rel="stylesheet">

	<!-- Custom css -->
	<link href="/Clients/TixNew/css/custom.css" rel="stylesheet">
<style>
.col-xs-12 {background: #222222; }

.yellow-bg  {
	-webkit-box-shadow: inset 0 2px 3px rgba(0, 0, 0, .12);
	box-shadow: inset 0 2px 3px rgba(0, 0, 0, .12);
	border-color: #FEC503;
	background-color: #FEC503;
  color:#fff;
}
.yellow-bg h2 {color:#fff;}
</style>
	<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
	<!--[if lt IE 9]>
			<script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
			<script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
		<![endif]-->

	<script type="text/javascript">

	    var appHome = angular.module('appHome', []);

	    appHome.controller('homeCtrl', ['$scope', function ($scope) {
	    }]);

	</script>

    <script type="text/javascript">
      var capterra_vkey = 'ecb168c4afc8ad9dd3853370e9fdada3',
      capterra_vid = '2002671',
      capterra_prefix = (('https:' == document.location.protocol) ? 'https://ct.capterra.com' : 'http://ct.capterra.com');

      function capterraTracking() {
      var ct = document.createElement('script'); ct.type = 'text/javascript'; ct.async = true;
      ct.src = capterra_prefix + '/capterra_tracker.js?vid=' + capterra_vid + '&vkey=' + capterra_vkey;
      var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ct, s);
      }
    </script>

    <script>
        (function (i, s, o, g, r, a, m) {
            i['GoogleAnalyticsObject'] = r; i[r] = i[r] || function () {
                (i[r].q = i[r].q || []).push(arguments)
            }, i[r].l = 1 * new Date(); a = s.createElement(o),
            m = s.getElementsByTagName(o)[0]; a.async = 1; a.src = g; m.parentNode.insertBefore(a, m)
        })(window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga');

        ga('create', 'UA-2391156-1', 'auto');
		ga('set', 'title', 'Home Page v1.02');
        ga('send', 'pageview');

        $(function () {

            $('#navWhy').on('click', function () {
                ga('send', 'event', 'Navigation', 'click', 'Nav Why Tix');
            });
            $('#navFeatures').on('click', function () {
                ga('send', 'event', 'Navigation', 'click', 'Nav Features');
            });
            $('#navPricing').on('click', function () {
                ga('send', 'event', 'Navigation', 'click', 'Nav Pricing');
            });
            $('#navWhoWeServe').on('click', function () {
                ga('send', 'event', 'Navigation', 'click', 'Nav Who We Serve');
            });
            $('#navTixBlog').on('click', function () {
                ga('send', 'event', 'Navigation', 'click', 'Tix Blog');
            });
            $('#navGetStarted').on('click', function () {
                ga('send', 'event', 'Navigation', 'click', 'Nav Get Started');
            });
            $('#navManagementLogin').on('click', function () {
                ga('send', 'event', 'Navigation', 'click', 'Nav Management Login');
            });

            $('#btnFreeDemo').on('click', function () {
                ga('send', 'event', 'Jumbotron', 'click', 'Jumbotron Free Demo');
            });

            $('#btnGetStarted').on('click', function () {
                ga('send', 'event', 'FreeSetUp', 'click', 'Button Get Started');
            });
            $('#lnkLearnMore').on('click', function () {
                ga('send', 'event', 'FreeSetUp', 'click', 'Link Learn More');
            });
            $('#btnEmail').on('click', function () {
                ga('send', 'event', 'FreeSetUp', 'click', 'Info Request Submitted');
            });

            $('.formSearchLink').on('click', function () {
                ga('send', 'event', 'InfoRequest', 'click', 'Search Link');
            });
            $('.formCustomerServiceLink').on('click', function () {
                ga('send', 'event', 'InfoRequest', 'click', 'Customer Service Link');
            });


            $('#btnSearch').on('click', function () {
                ga('send', 'event', 'Search', 'click', 'Search');
            });

            $('#whyNoStartUpCosts').on('click', function () {
                ga('send', 'event', 'WhyTix', 'click', 'No Start Up Costs');
            });

            $('#whyLowServiceFees').on('click', function () {
                ga('send', 'event', 'WhyTix', 'click', 'Low Service Fees');
            });

            $('#whyEasyToUse').on('click', function () {
                ga('send', 'event', 'WhyTix', 'click', 'Easy To Use');
            });

            $('#whyMobileSalesScanning').on('click', function () {
                ga('send', 'event', 'WhyTix', 'click', 'Mobile Sales and Barcode Scanning');
            });

            $('#whyServiceSupport').on('click', function () {
                ga('send', 'event', 'WhyTix', 'click', 'Service and Support');
            });

            $('#whySatisfactionGuaranteed').on('click', function () {
                ga('send', 'event', 'WhyTix', 'click', 'Satisfaction Guaranteed');
            });

            $('#featureEasyIntegration').on('click', function () {
                ga('send', 'event', 'Features', 'click', 'Easy Integration');
            });

            $('#featureSellTickets').on('click', function () {
                ga('send', 'event', 'Features', 'click', 'Sell Tickets');
            });

            $('#featureSeatingOptions').on('click', function () {
                ga('send', 'event', 'Features', 'click', 'Seating Options');
            });

            $('#featureCRM').on('click', function () {
                ga('send', 'event', 'Features', 'click', 'CRM');
            });

            $('#featureEngagePatrons').on('click', function () {
                ga('send', 'event', 'Features', 'click', 'Engage Patrons');
            });

            $('#featureEmailMarketing').on('click', function () {
                ga('send', 'event', 'Features', 'click', 'Email Marketing');
            });

            $('#featureDonations').on('click', function () {
                ga('send', 'event', 'Features', 'click', 'Donations/Memberships');
            });

            $('#featureMobileBoxOffice').on('click', function () {
                ga('send', 'event', 'Features', 'click', 'Mobile Box Office');
            });

            $('#featureSubscriptions').on('click', function () {
                ga('send', 'event', 'Features', 'click', 'Season Subscriptions');
            });

            $('#featureAnalytics').on('click', function () {
                ga('send', 'event', 'Features', 'click', 'Analytics');
            });

            $('#featureBarcodeScanning').on('click', function () {
                ga('send', 'event', 'Features', 'click', 'Barcode Scanning');
            });

            $('#featurePromoteBrand').on('click', function () {
                ga('send', 'event', 'Features', 'click', 'Promote Your Brand');
            });


            $('#footerCapterra').on('click', function () {
                ga('send', 'event', 'Footer', 'click', 'Capterra');
            });

            $('#footerFacebook').on('click', function () {
                ga('send', 'event', 'Share', 'click', 'Facebook');
            });

            $('#footerTwitter').on('click', function () {
                ga('send', 'event', 'Share', 'click', 'Twitter');
            });

            $('#footerGoogle').on('click', function () {
                ga('send', 'event', 'Share', 'click', 'Google');
            });

            $('#footerEmailTix').on('click', function () {
                ga('send', 'event', 'Footer', 'click', 'Email Tix');
            });

            $('#footerWhyTix').on('click', function () {
                ga('send', 'event', 'Footer', 'click', 'Why Tix');
            });

            $('#footerFeatures').on('click', function () {
                ga('send', 'event', 'Footer', 'click', 'Features');
            });

            $('#footerPricing').on('click', function () {
                ga('send', 'event', 'Footer', 'click', 'Pricing');
            });

            $('#footerWhoWeServe').on('click', function () {
                ga('send', 'event', 'Footer', 'click', 'Who We Serve');
            });

            $('#footerTixBlog').on('click', function () {
                ga('send', 'event', 'Footer', 'click', 'Tix Blog');
            });

            $('#footerTicketBuyerLogin').on('click', function () {
                ga('send', 'event', 'Footer', 'click', 'Ticket Buyer Login');
            });

            $('#footerTixClientLogin').on('click', function () {
                ga('send', 'event', 'Footer', 'click', 'Footer Management Login');
            });

            $('#footerPrivacyPolicy').on('click', function () {
                ga('send', 'event', 'Footer', 'click', 'PrivacyPolicy');
            });

            $('#footerTermsOfUse').on('click', function () {
                ga('send', 'event', 'Footer', 'click', 'Terms Of Use');
            });

        });
    </script>
</head>

<!-- body classes:
			"boxed": boxed layout mode e.g. <body class="boxed">
			"pattern-1 ... pattern-9": background patterns for boxed layout mode e.g. <body class="boxed pattern-1">
-->

<body class="front no-trans" ng-app="appHome">
	<form id="form1" runat="server" ng-controller="homeCtrl" ng-submit="submit($event)" >
		<!-- PAGE START -->
		<div class="page-wrapper">

			<!-- super header -->
			<div class="header-top dark" style="background-color: #222;">
<div class="container">
				<div class="row">

					<div class="col-md-12 col-xs-12 ">

						<!-- header-top-second start -->
						<!-- ================ -->
						<div id="header-top-second"  class="clearfix">

							<!-- header top dropdowns start -->
							<!-- ================ -->
							<div class="header-top-dropdown pull-right">

								<div class="btn-group dropdown">
									<a id="btnSearch" href="https://www.tix.com/search.aspx" type="button" class="btn"><i class="fa fa-search">&nbsp;</i>&nbsp;Find Events</a>
								</div>

							</div>
							<!--  header top dropdowns end -->

						</div>
						<!-- header-top-second end -->

					</div>

				</div>
			</div>
			<!-- / super header -->
</div>

			<!-- HEADER START -->
			<header class="header dark fixed clearfix  dark-bg">

<div class="container">
<div class="row">
						<div class="col-md-3 visible-md visible-lg ">

							<!-- header-left start -->
							<div class="header-left clearfix">

								<!-- logo -->
								<div class="logo smooth-scroll">
									<a href="#header-top">
										<img src="/Clients/TixNew/images/TixLogo512InverseDropShadow.png" alt="tix" />
									</a>
								</div>

								<!-- slogan -->
								<div class="site-slogan">
									it's the ticket!
								</div>

							</div>
							<!-- header-left end -->

						</div>
						<div class="col-xs-3 visible-xs visible-sm">

							<!-- header-left start -->
							<div class="header-left clearfix">

								<!-- logo -->
								<div class="logo smooth-scroll">
									<a href="#header-top">
									<br />
										<img src="/Clients/TixNew/images/TixLogo512InverseDropShadow.png" width="10%" alt="tix" />
									</a>

								</div>

								<!-- slogan -->


							</div>
							<!-- header-left end -->

						</div>


						<div class="col-md-9 ">

							<!-- header-right start -->
							<div class="clearfix">

								<!-- main-navigation start -->
								<div class="main-navigation animated">

									<!-- navbar start -->
                  <nav class="navbar navbar-default" role="navigation">
                    <div class="container-fluid">
											<div class="navbar-header">
												<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navbar-collapse-1">
													<span class="sr-only">Toggle navigation</span>
													<span class="icon-bar"></span>
													<span class="icon-bar"></span>
													<span class="icon-bar"></span>
												</button>
											</div>

											<!-- the nav links -->
											<div class="collapse navbar-collapse scrollspy smooth-scroll" id="navbar-collapse-1">
												<ul class="nav navbar-nav">
													<li><a id="navWhy" href="#why">Why Tix?</a></li>
													<li><a id="navFeatures" href="#features">Features</a></li>
													<li><a id="navPricing" href="#pricing">Pricing</a></li>
													<li><a id="navWhoWeServe" href="#serve">Who We Serve</a></li>
													<li><a id="navTixBlog" href="http://blog.tix.com">Tix Blog</a></li>
													<li><a id="navGetStarted" href="" class="openModal" data-toggle="modal" data-id="priority1" data-target="#emailModal" >Get Started</a></li>
												</ul>
											</div>



									</nav>
									<!-- navbar end -->

								</div>
								<!-- main-navigation end -->

							</div>
							<!-- header-right end -->

						</div>



</div></div>



			</header>
			<!-- HEADER END -->

			<!-- BANNER START -->
			<!-- ================ -->
			<div class="banner">

				<div class="jumbotron  background-image">
					<div class="container text-center">
						<h1 class="dark-text text-shadow1">Bringing success to your events</h1>
						<p class="dark-text text-shadow2W">It's why we're here.</p>
						<p class="dark-text text-shadow2W">State-of-the-art, cloud-based ticketing.</p>
						<p class="dark-text text-shadow2W">Find out why thousands of organizations choose Tix.</p>
						<a id="btnFreeDemo" href="" class="btn btn-lg btn-demo openModal" data-toggle="modal" data-id="priority3" data-target="#emailModal" >Free Demo</a>
					</div>
				</div>

			</div>
			<!-- BANNER END -->


			<!-- TESTIMONIAL START -->
			<div class="section yellow-bg clearfix">

<div class="row">
<div class="visible-lg ">
<img src="https://assets.capterra.com/badge/122f66800f163085bc146c1bb1fbe362.png?v=2002671&p=9322" style="position:absolute; top:11%; left: 1%; z-index:5;">
</div>
</div>
				<div class="owl-carousel content-slider">







						<div class="item active testimonial">
							<div class="row">
								<div class="col-md-12 text-center">

									<h2 class="title text-shadow3">THE TOOLS TO MAKE YOUR JOB EASIER</h2>
									<div class="testimonial-body">
										<p class="quote text-shadow3">Our box office runs more efficiently and smoothly since we switched to Tix.</p>
										<div class="testimonial-info-1">- Kristin Ramsey</div>
										<div class="testimonial-info-2">Ball State University</div>
									</div>

								</div>
							</div>
						</div>

						<div class="item testimonial">
							<div class="row">
								<div class="col-md-12 text-center">

									<h2 class="title text-shadow3">WE'RE THERE WHEN YOU NEED US</h2>
									<div class="testimonial-body">
										<p class="quote text-shadow3">Tix offers the most friendly & efficient customer service in the ticketing industry.</p>
										<div class="testimonial-info-1">- Joshua Westwick</div>
										<div class="testimonial-info-2">South Dakota State University</div>
									</div>

								</div>
							</div>
						</div>

						<div class="item testimonial">
							<div class="row">
								<div class="col-md-12 text-center">

									<h2 class="title text-shadow3">A SYSTEM DESIGNED WITH YOU IN MIND</h2>
									<div class="testimonial-body">
										<p class="quote text-shadow3">Tix has provided a first class ticketing system for our organization.</p>
										<div class="testimonial-info-1">- Sue Talford</div>
										<div class="testimonial-info-2">Boerne Performing Arts</div>
									</div>

								</div>
							</div>
						</div>

						<div class="item testimonial">
							<div class="row">
								<div class="col-md-12 text-center">

									<h2 class="title text-shadow3">ELIMINATE THE BARRIERS TO YOUR SUCCESS</h2>
									<div class="testimonial-body">
										<p class="quote text-shadow3">We've had a wonderful experience with Tix. It's easy and our ticket buyers love the convenience.</p>
										<div class="testimonial-info-1">- Gaye Wutzke</div>
										<div class="testimonial-info-2">Mid-Columbia Ballet</div>
									</div>

								</div>
							</div>
						</div>

						<div class="item testimonial">
							<div class="row">
								<div class="col-md-12 text-center">

									<h2 class="title text-shadow3">FIVE STAR RATING</h2>
									<div class="testimonial-body">
										<p class="quote text-shadow3 rating"><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i></p>
										<div class="testimonial-info-1">- Users</div>
										<div class="testimonial-info-2">Capterra Software Reviews</div>
									</div>

								</div>
							</div>
						</div>

					</div>
				</div>
			</div>

			<!-- TESTIMONIAL END -->

			<!-- MAIN SECTION START -->
			<section class="main-container object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="300">

				<!-- WHY TIX? START -->
				<div class="section clearfix">
					<div class="container">


						<h1 class="text-center space-top" id="why">Why Tix?</h1>
						<div class="separator"></div>
						<p class="lead text-center"></p>
						<br/>

						<div class="row">

							<div class="col-md-6">
								<h2 class="title">Your Complete Ticketing Solution</h2>
								<div class="row">
									<div class="col-md-6">
										<img src="/Clients/TixNew/images/TixLogoComplete.gif" alt="" />
									</div>
									<div class="col-md-6">
										<p>Tix is a state-of-the-art, cloud-based ticketing system that features fully integrated access controls, event management controls, multi-channel distribution capabilities, and a robust reporting suite. Tix provides a customer-facing ticket sales page, as well as inventory controls, invoicing and financial accountability.</p>
									</div>
								</div>
								<p>We specialize in no-cost, feature-rich ticketing solutions for venues, promoters, producers, universities, theme parks, tours, museums, casinos, theatres, film festivals, concerts, night clubs, music festivals, race tracks, and more.</p>

								<div class="space hidden-md hidden-lg"></div>
							</div>

							<div class="col-md-6">
								<div class="panel-group panel-dark" id="accordion">
									<div class="panel panel-default">
										<div class="panel-heading">
											<h4 class="panel-title">
												<a id="whyNoStartUpCosts" data-toggle="collapse" data-parent="#accordion" href="#collapseOne">No Start Up Costs
												</a>
											</h4>
										</div>
										<div id="collapseOne" class="panel-collapse collapse in">
											<div class="panel-body">
												No set up fees, software costs, annual maintenance fees or other hidden costs...absolutely risk-free.
											</div>
										</div>
									</div>
									<div class="panel panel-default">
										<div class="panel-heading">
											<h4 class="panel-title">
												<a id="whyLowServiceFees" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo" class="collapsed">Low, Low Service Fees
												</a>
											</h4>
										</div>
										<div id="collapseTwo" class="panel-collapse collapse">
											<div class="panel-body">
												Our service fees are among the lowest in the ticketing industry. Our low service fees result in increased affordability for your ticket buyers and increased attendance for your events.
											</div>
										</div>
									</div>
									<div class="panel panel-default">
										<div class="panel-heading">
											<h4 class="panel-title">
												<a id="whyEasyToUse" data-toggle="collapse" data-parent="#accordion" href="#collapseThree" class="collapsed">Easy To Use
												</a>
											</h4>
										</div>
										<div id="collapseThree" class="panel-collapse collapse">
											<div class="panel-body">
												With our intuitive ticket sales software, training is a snap. Your box office will be up to speed in no time.
											</div>
										</div>
									</div>

									<div class="panel panel-default">
										<div class="panel-heading">
											<h4 class="panel-title">
												<a id="whyMobileSalesScanning" data-toggle="collapse" data-parent="#accordion" href="#collapseFour" class="collapsed">Mobile Ticket Sales and Barcode Scanning
												</a>
											</h4>
										</div>
										<div id="collapseFour" class="panel-collapse collapse">
											<div class="panel-body">
												Sell tickets from your iPhone, iPad or other mobile device.  You can also scan barcodes at real-time using your iPhone, iPod Touch or iPad.
											</div>
										</div>
									</div>

									<div class="panel panel-default">
										<div class="panel-heading">
											<h4 class="panel-title">
												<a id="whyServiceSupport" data-toggle="collapse" data-parent="#accordion" href="#collapseFive" class="collapsed">24/7 Service and Support
												</a>
											</h4>
										</div>
										<div id="collapseFive" class="panel-collapse collapse">
											<div class="panel-body">
												We make ourselves available to you 24/7, 365 days a year.  It's not lip service - it's a promise.
											</div>
										</div>
									</div>

									<div class="panel panel-default">
										<div class="panel-heading">
											<h4 class="panel-title">
												<a id="whySatisfactionGuaranteed" data-toggle="collapse" data-parent="#accordion" href="#collapseSix" class="collapsed">Satisfaction Guaranteed
												</a>
											</h4>
										</div>
										<div id="collapseSix" class="panel-collapse collapse">
											<div class="panel-body">
												We won't lock you into a long-term contract. We put ourselves in a position to earn your business, and we will.
											</div>
										</div>
									</div>


								</div>
							</div>

						</div>

					</div>
				</div>
				<!-- WHY TIX? END -->




				<!-- FEATURES START -->
				<div class="section gray-bg clearfix">

					<div class="container">

						<br />
						<h1 class="text-center space-top" id="features">Features</h1>
						<div class="separator"></div>
						<p class="lead text-center">
							Tix features an easy-to-use interface, a robust reporting suite, marketing tools to help keep your customers engaged, and the ability for you to access all of your ticket sales and donation information in one place.<br />
							It's ticketing software designed with you in mind.
						</p>
						<br />

						<!-- Begin Easy Integration  -->
						<div class="row grid-space-10">

							<div class="col-sm-4">
								<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="0">
									<div class="icon-container default-bg">
										<i class="fa fa-gears"></i>
									</div>
									<div class="body">
										<h2>Easy Integration</h2>
										<p>Tix seamlessly integrates into your box office operations. The Tix system is easy to learn, and teach - you'll have your box office staff trained in no time. Online ticket sales take place on a private label page that is designed to look and feel like your website. It can be customized to have the same look and feel of your existing web site, complete with your logos, banners, links, fonts, and colors.</p>
										<a id="featureEasyIntegration" href="" data-toggle="modal" data-target="#EasyIntegration">Learn More</a>

									</div>
								</div>
							</div>
							<div class="modal fade" id="EasyIntegration" tabindex="-1" role="dialog" aria-labelledby="EasyIntegrationLabel" aria-hidden="true">
								<div class="modal-dialog">
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
											<h4 class="modal-title" id="H2">Easy Integration</h4>
										</div>
										<div class="modal-body">
											<p>
												<b>Credit Card Processing</b><br/>
												<b>Bring your own</b> -Tix is compatible with over 30 different e-commerce payment gateways including Authorize.net, Cybersource, Global Gateway, Virtual Merchant, Stripe, PayPal and many more.  Tix does not charge an additional fee if you use your own merchant account. When using your merchant account for credit card processing, ticket revenue goes directly into your account within 48-72 hours after each ticket purchase.<br/>
												<br/>
												<b>Let Tix Handle it</b> - If you do not have the time, or if you do not wish to incur the expense of setting up your own merchant account, Tix can handle the credit card processing for your organization. If you wish to use the Tix merchant account we charge an additional fee of 5% of the ticket price for credit card processing. When using our merchant account for credit card processing, we send you a check the week after the event.
											</p>
											<p>
												<b>Ticket Printing</b><br />
												<b>E-Tickets</b> - Let your ticket buyers print their own tickets at home. Each E-Ticket is uniquely barcoded for added peace of mind.
											</p>
											<p><b>Thermal Ticket Printing</b> - Tix interfaces with BOCA, Practical Automation, and Datamax thermal ticket printers. Print tickets on demand in advance and in the box office.</p>
											<p><b>Pre-printed Tickets</b> - Don’t have your own ticket printer? Let Tix print tickets for you. We can print a subset of tickets or the whole house. </p>
											<p><b>Other options</b> - Tix also supports some thermal receipt printers, standard inkjet/laser printers, and can support a ticketless Will Call option. </p>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-sm btn-dark" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>
							<!-- End Easy Integration -->

							<!-- Begin Sell Tickets -->
							<div class="col-sm-4">
								<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="200">
									<div class="icon-container default-bg">
										<i class="fa fa-ticket"></i>
									</div>
									<div class="body">
										<h2>Sell Tickets</h2>
										<p>Tix can accommodate orders taken by Phone, Fax, Mail, Box Office, and Internet. Tix also offers an optional 24/7 Call Center service that allows ticket buyers to speak with a US based live operator for ticket ordering. You can use any combination of our services to sell your event tickets.</p>
										<a id="featureSellTickets" href="" data-toggle="modal" data-target="#SellTickets">Learn More</a>
									</div>
								</div>
							</div>
							<div class="modal fade" id="SellTickets" tabindex="-1" role="dialog" aria-labelledby="SellTicketsLabel" aria-hidden="true">
								<div class="modal-dialog">
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
											<h4 class="modal-title" id="H1">Sell Tickets</h4>
										</div>
										<div class="modal-body">
											<p>
												<b>ONLINE</b><br />
												<b>Private Label</b> - Tix seamlessly integrates ticket purchasing into your existing web site.
											</p>
											<p><b>Mobile Friendly</b> - Mobile ticket sales are increasing at a rapid pace. Tix has a mobile friendly site to insure your patrons can purchase your tickets on mobile devices and tablets. </p>
											<p><b>E-Tickets/Print @ Home Tickets</b> - Allow your ticket buyers to print their own tickets saving you time and money and freeing your box office staff up to sell more tickets. </p>
											<p><b>Secure</b> - Tix employs 128 bit Secure Sockets Layer (SSL) Encryption to make sure that sensitive information is secure as it's transmitted to and from your ticket buyer and the credit card processors.</p>
											<p>
												<b>BOX OFFICE</b>
												<br />
												<b>Easy to Use</b> - With our intuitive ticket sales software, training is a snap. Your box office will be up to speed in no time.
											</p>
											<p><b>Touch Screen Compatible</b> - Take advantage of our touch screen program to speed up your walk-up transactions, free up counter space and reduce the amount of hardware required. </p>
											<p><b>Card Swipe</b> - Streamline your walk-up ticket sales with compatible credit card swipes.</p>

											<p>
												<b>Call Center</b>
												<br />
												Our U.S. based operators are standing by 24 hours a day, 7 days a week, ready to take their phone ticket orders through our optional toll-free Call Center.
											</p>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-sm btn-dark" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>
							<!-- End Sell Tickets -->

							<!-- Begin Promote -->
							<div class="col-sm-4">
								<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="400">
									<div class="icon-container default-bg">
										<i class="icon icon-seats"></i>
									</div>
									<div class="body">
										<h2>Multiple Seating Options</h2>
										<p>We support reserved seating, general admission seating and can handle events with combination reserved and general admission seating. We program your seating charts for you at absolutely no cost.</p>
										<a id="featureSeatingOptions" href="" data-toggle="modal" data-target="#ReservedSeating">Learn More</a>
									</div>
								</div>
							</div>
							<div class="modal fade" id="ReservedSeating" tabindex="-1" role="dialog" aria-labelledby="ReservedSeatingLabel" aria-hidden="true">
								<div class="modal-dialog">
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
											<h4 class="modal-title" id="H4">Multiple Seating Options</h4>
										</div>
										<div class="modal-body">
											<p><b>Seat Selection</b> - Patrons love choosing their own seats using our interactive graphical seat maps. Different patrons have different seating preferences. Tix allows you to accommodate them while taking the load off of your box office staff.Tix has 1000’s of seat maps on file. If we don’t have it, we will program it for you free of charge.</p>
											<p><b>Best Available</b> - Tix can be configured to assign best availability seating by price tier based on the seating priorities you specify.</p>
											<p><b>Photographic Seat View</b> - Show your ticket buyer what the view from their seats will look like!  Tix gives your patrons the ability to view photographs from each of the seat locations giving them better tools to insure they’ll enjoy your events and buy more tickets. </p>
											<p><b>Unlimited</b> - Our system supports an unlimited number of venues and seating configurations for your organization.</p>
											<p><b>Flexible</b> - Tix supports complex seating arrangements, including venues with combined reserved and general admission seating.</p>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-sm btn-dark" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>

						</div>
						<!-- End Seating -->

						<div class="row grid-space-10">
							<div class="col-sm-4">
								<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="600">
									<div class="icon-container default-bg">
										<i class="fa fa-users"></i>
									</div>
									<div class="body">
										<h2>CRM</h2>
										<p>Enhance the relationship you have with your ticket buyers using our suite of customer reports, Email marketing tools, and customer history tracking.  Our CRM tools will help your organization understand and grow your patron base.</p>
										<a id="featureCRM" href="" data-toggle="modal" data-target="#CRM">Learn More</a>
									</div>
								</div>
							</div>
							<div class="modal fade" id="CRM" tabindex="-1" role="dialog" aria-labelledby="CRMLabel" aria-hidden="true">
								<div class="modal-dialog">
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
											<h4 class="modal-title" id="H3">CRM (Customer Relationship Management)</h4>
										</div>
										<div class="modal-body">
											<p>Generate customer lists based on purchase history or entry date into the customer database.  Customer information (name, address, phone number, email address, customer classifications) can be updated at real-time, and our Merge Customer History program allows authorized users to manage any duplicate customer records that have been created.</p>
											<p>Discover your most important patrons - Who buys the most tickets? Who are your most important donors?</p>
											<p>Keep first time buyers coming back - Instantly generate a list of first time buyers and invite them back!</p>
											<p>Stay connected with donors, members, subscribers and repeat buyers</p>
											<p>Identify and create groups of different customer types</p>
											<p>Detailed customer history - Develop segments based on past purchase history</p>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-sm btn-dark" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>
							<!-- End CRM -->

							<div class="col-sm-4">
								<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="800">
									<div class="icon-container default-bg">
										<i class="fa fa-comments-o"></i>
									</div>
									<div class="body">
										<h2>Engage Your Patrons</h2>
										<p>Use our tools and reports to create ongoing, meaningful interactions with your patrons. Know who your patrons are and generate targeted customer lists to use in your marketing efforts. </p>
										<a id="featureEngagePatrons" href="" data-toggle="modal" data-target="#Engage">Learn More</a>
									</div>
								</div>
							</div>
							<div class="modal fade" id="Engage" tabindex="-1" role="dialog" aria-labelledby="EngageLabel" aria-hidden="true">
								<div class="modal-dialog">
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
											<h4 class="modal-title" id="H5">Engage Your Patrons</h4>
										</div>
										<div class="modal-body">
											<p><b>Social</b> - Post your event to <b>Facebook</b> and generate buzz about your next event.  Tix makes it easy to post your events on your <b>Facebook</b> Fan pages and allow your ticket buyers to share their purchase and information about your event on their social networking pages including <b>Facebook</b> and <b>Twitter</b>. </p>
											<p><b>Surveys</b> - We can customize demographic data collection to suit your needs. We can collect anything from the simple "How did you hear about us?" to sophisticated surveys with multiple choice and free-form answers.</p>
											<p><b>Donations</b> - You can solicit and accept donations and memberships for your organization. Tix allows you to offer pre-set levels and/or open donation amounts. Quickly and easily generate donation reports, and use that information to thank your donors for supporting your organization and tell them why they matter. </p>
											<p><b>QR Codes</b> - Easily generate QR codes for use in marketing communications. Scanning the code with a mobile device takes the ticket buyer directly to a mobile optimized ticket sales page.</p>
											<p><b>Discount Codes</b> - Discount codes give your ticket buyers an incentive to purchase tickets. Provide an amount or percentage off each ticket. Encourage patrons to bring their friends with group discounts. Improve advanced sales with limited-time promotions. </p>
											<p><b>Renewals</b> - Stay in touch with your subscribers and make it easy for them to renew their subscription each season with our automated subscription renewal process.</p>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-sm btn-dark" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>
							<!-- End Engage -->


							<div class="col-sm-4">
								<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="1000">
									<div class="icon-container default-bg">
										<i class="fa fa-envelope-o"></i>
									</div>
									<div class="body">
										<h2>Email Marketing</h2>
										<p>Email your patrons directly at any time through Tix. Contact them to let them know about an upcoming event or simply thank them for purchasing tickets to a past event. Tix helps organizations like yours build strong relationships with your patrons.</p>
										<a id="featureEmailMarketing" href="" data-toggle="modal" data-target="#Email">Learn More</a>
									</div>
								</div>
							</div>
							<div class="modal fade" id="Email" tabindex="-1" role="dialog" aria-labelledby="EmailLabel" aria-hidden="true">
								<div class="modal-dialog">
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
											<h4 class="modal-title" id="H6">Email Marketing</h4>
										</div>
										<div class="modal-body">
											<p>Tix makes communicating with your ticket buyers easy.  Tix can be used to send an email blast to past ticket buyers letting them know about an upcoming event.  Our e-mail notification program can also be used to inform patrons of important information such as a cancellation, postponement, line-up change, or parking information related to an event they’ve already purchased tickets to.</p>
											<p>Email notifications are logged and communication history can be viewed when viewing customer details. </p>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-sm btn-dark" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>
							<!-- End CRM -->
						</div>

						<div class="row grid-space-10">
							<div class="col-sm-4">
								<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="600">
									<div class="icon-container default-bg">
										<i class="fa fa-gift"></i>
									</div>
									<div class="body">
										<h2>Donations/Memberships</h2>
										<p>Tix can be used to process donations or membership sales at the various giving/membership levels allowed by your organization.  Tix can be programmed to give discounts to ticket buyers based on their purchase history, including donations and memberships.</p>
										<a id="featureDonations" href="" data-toggle="modal" data-target="#Donations">Learn More</a>
									</div>
								</div>
							</div>
							<div class="modal fade" id="Donations" tabindex="-1" role="dialog" aria-labelledby="DonationsLabel" aria-hidden="true">
								<div class="modal-dialog">
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
											<h4 class="modal-title" id="H8">Donations and Memberships</h4>
										</div>
										<div class="modal-body">
											<p>The donation/membership solicitation can be programmed to appear during the ticket purchase process.  You can also link directly to the donation/membership solicitation so that your patrons can contribute to your organization independent of making a ticket purchase.</p>
											<p>Tix offers the ability to add and track sponsor and donor information in a manner that reduces unnecessary work and facilitates revenue generation for your organization.</p>
											<p>Pledge reminders to donors can be created in the Tix system for automatic follow-up.</p>
											<p>Tix supports customer donations and membership renewals online and through the box office system.</p>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-sm btn-dark" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>
							<!-- End Donations -->
							<div class="col-sm-4">
								<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="800">
									<div class="icon-container default-bg">
										<i class="fa fa-mobile"></i>
									</div>
									<div class="body">
										<h2>Mobile Box Office</h2>
										<p>Take Tix with you on your iPad, iPhone or other mobile device, and sell tickets without needing to install an app.  Use Tix to process real-time ticket sales and accept credit card payments on your mobile device. </p>
										<a id="featureMobileBoxOffice" href="" data-toggle="modal" data-target="#Mobile">Learn More</a>
									</div>
								</div>
							</div>
							<div class="modal fade" id="Mobile" tabindex="-1" role="dialog" aria-labelledby="MobileLabel" aria-hidden="true">
								<div class="modal-dialog">
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
											<h4 class="modal-title" id="H7">Mobile</h4>
										</div>
										<div class="modal-body">
											<p>Mobile ticket sales are increasing at a rapid pace. Tix has a mobile friendly site to ensure your patrons can purchase tickets to your events on their mobile devices and tablets.</p>
											<p>Our mobile-optimized ticket sales pages allow your patrons to easily complete their ticket orders on their mobile device or tablet.</p>
											<p>Your patrons can still access all of the ticket-buying options available on our mobile-optimized ticket sales pages, including the abilty for them to select a seat.</p>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-sm btn-dark" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>
							<!-- End Email Mobile -->
							<div class="col-sm-4">
								<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="1000">
									<div class="icon-container default-bg">
										<i class="fa fa-calendar"></i>
									</div>
									<div class="body">
										<h2>Season Subscriptions</h2>
										<p>Tix can handle most any season ticket or subscription need, including "build-your-own" or fixed packages. Additionally, we offer same-seat season subscription renewals so that your patrons can purchase the seats they held the previous season.</p>
										<a id="featureSubscriptions" href="" data-toggle="modal" data-target="#SeasonSub">Learn More</a>
									</div>
								</div>
							</div>
							<div class="modal fade" id="SeasonSub" tabindex="-1" role="dialog" aria-labelledby="SeasonSubLabel" aria-hidden="true">
								<div class="modal-dialog">
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
											<h4 class="modal-title" id="H10">Season Subscriptions</h4>
										</div>
										<div class="modal-body">
											<p>Tix offers various season ticket/subscription options, including:</p>
											<p><b>Fixed Season Subscriptions</b> where the patron gets the same seat across all of the shows in the subscription.</p>
											<p><b>Build Your Own Subscriptions</b> where the patron selects their own seat for all of the shows included in the subscription and then receives a discount at checkout.</p>
											<p><b>Flexible Subscriptions (Flex Pass)</b> where the patron gets a voucher for each of the events included in the subscription.  The vouchers can then be exchanged for individual event tickets through the box office.</p>
											<p>Tix can automatically generate season ticket renewal orders that include the seats held by the subscriber for the previous season.  Renewal expiration dates and times can be pre-configured to release season tickets that have not been renewed by a specified date and time.  The Tix system can be used to generate customized season ticket renewal letters as well as season ticket renewal e-mails.  Customers can renew tickets online by entering their Tix order number, Renewal Code, and credit card payment information.  Box office users can renew season ticket orders via order number, customer lookup (name, phone number, e-mail address, etc.), or seat location and applying any applicable payment method.</p>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-sm btn-dark" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>
						</div>
						<!-- End Season Subscriptions -->
						<div class="row grid-space-10">
							<div class="col-sm-4">
								<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="600">
									<div class="icon-container default-bg">
										<i class="fa fa-line-chart"></i>
									</div>
									<div class="body">
										<h2>Analytics</h2>
										<p>Tix includes a variety of reporting tools which allow authorized users to separate data by event, event type, event category, method of payment, order type, cashier, as well as by event date range and transaction date range.</p>
										<a id="featureAnalytics" href="" data-toggle="modal" data-target="#Analytics">Learn More</a>
									</div>
								</div>
							</div>
							<div class="modal fade" id="Analytics" tabindex="-1" role="dialog" aria-labelledby="AnalyticsLabel" aria-hidden="true">
								<div class="modal-dialog">
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
											<h4 class="modal-title" id="H11">Analytics</h4>
										</div>
										<div class="modal-body">
											<p>Tix features a robust and sophisticated reporting suite that can provide organizations with the type of data needed for in-depth financial and marketing analysis.</p>
											<p><b>Extensive</b> - View the data you need, when you need it.  Tix offers a full suite of over 40 reports to provide you with ticket sales data in real-time.</p>
											<p><b>Customizable</b> - View report data that is important to you. Tix reports are highly customizable to allow custom filtering, sorting, grouping, as well as the ability to customize the columns displayed and the sequence of the columns displayed. Report customization can be configured by the user and saved for later re-use.</p>
											<p><b>Exportable</b> - Easily export sales and patron data to Excel, PDF, or CSV.</p>
											<p>Tix can be configured to include Google Analytics tracking codes for conversion tracking.</p>

										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-sm btn-dark" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>
							<!-- End Analytics -->
							<div class="col-sm-4">
								<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="800">
									<div class="icon-container default-bg">
										<i class="fa fa-qrcode"></i>
									</div>
									<div class="body">
										<h2>Barcode Scanning</h2>
										<p>Tix offers real-time barcode scanning through its proprietary TixScan app on iOS devices.  Ticket validation can be performed on E-Tickets (Print-at-Home) and/or hard tickets for validation and attendance reporting.</p>
										<a id="featureBarcodeScanning" href="" data-toggle="modal" data-target="#AccessControl">Learn More</a>
									</div>
								</div>
							</div>
							<div class="modal fade" id="AccessControl" tabindex="-1" role="dialog" aria-labelledby="AccessControlLabel" aria-hidden="true">
								<div class="modal-dialog">
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
											<h4 class="modal-title" id="H12">Barcode Scanning</h4>
										</div>
										<div class="modal-body">
											<p>The Tix scanning application can be run in a linked mode in which all scanners are connected to the Tix centralized database via the internet or in a standalone mode where each scanner is independent without the need for an internet connection.  The Tix scanning application is compatible with a variety of barcode scanners. </p>
											<p><b>iPhone Mobile Scanning App</b> - Use the Tix Scan app in conjunction with the Linea Pro scanning cradle. Ideal for organizations that require easy integration with their existing infrastructure.</p>
											<p><b>Wired USB Barcode Scanning</b> - USB barcode scanners plug into a laptop or PC and interface with the Tix E-Ticket scanning program. USB barcode scanners are easy to use and provide a cost-effective solution for access control.</p>
											<p><b>Wireless Scanning</b> - Wireless scanners run on Pocket-PC’s running a proprietary Tix Scan application. Wireless scanners are optimal for high volume events where quick scanning and long battery life is a priority.</p>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-sm btn-dark" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>
							<!-- End Access Control -->

							<div class="col-sm-4">
								<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="400">
									<div class="icon-container default-bg">
										<i class="fa fa-bullhorn"></i>
									</div>
									<div class="body">
										<h2>Promote Your Brand</h2>
										<p>Our private label solution seamlessly integrates ticket purchasing into your website. It can be customized to have the same look and feel of your existing web site, complete with your logos, banners, links, fonts, and colors.</p>
										<a id="featurePromoteBrand" href="" data-toggle="modal" data-target="#Promote">Learn More</a>
									</div>
								</div>
							</div>
							<div class="modal fade" id="Promote" tabindex="-1" role="dialog" aria-labelledby="PromoteLabel" aria-hidden="true">
								<div class="modal-dialog">
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
											<h4 class="modal-title" id="H13">Promote Your Brand</h4>
										</div>
										<div class="modal-body">
											<p>While some services include a branded banner at the top of the ticketing pages, Tix wraps your web page around our ticketing engine which includes your logos, colors, graphics, navigation, sponsors, etc.  This provides a seamless integration of ticket sales functionality with your website, resulting in an improved customer experience where additional information about your organization is only a click away. Our mobile-optimized ticket sales pages can also be branded with your organization's logo and colors.</p>
											<p>Print-at-home tickets can be customized to include your organization's logos and colors, as well as venue driving directions, a map of the venue location, and event-specific advertising.</p>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-sm btn-dark" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>
							<!-- End Season Subscriptions -->

						</div>

						<!-- boxes end -->

					</div>

				</div>
				<!-- FEATURES END -->


				<!-- section start -->
				<!-- ================ -->
				<div class="section parallax parallax-bg dark-translucent-bg">

					<div class="container">

						<div class="call-to-action">
							<h1>Safe & Secure</h1>
						</div>

						<div class="owl-carousel content-slider">

							<div class="testimonial-safe">
								<div class="container">
									<div class="row">
										<div class="col-md-12">
											<h2 class="title">SECURITY IS TOP PRIORITY AT TIX</h2>

											<div class="testimonial-safe-body">
												<p>Without the confidence that their information is secure, ticket buyers simply won't buy tickets.</p>

											</div>
										</div>
									</div>
								</div>
							</div>

							<div class="testimonial-safe">
								<div class="container">
									<div class="row">
										<div class="col-md-12">
											<h2 class="title" style="text-transform: uppercase;">Payment Card Industry (PCI) Level 1 Certified.</h2>

											<div class="testimonial-safe-body">
												<p>PCI Level 1 is the highest (most secure) level of certification available from the Payment Card Industry. </p>

											</div>
										</div>
									</div>
								</div>
							</div>

							<div class="testimonial-safe">
								<div class="container">
									<div class="row">
										<div class="col-md-12">
											<h2 class="title" style="text-transform: uppercase;">128 bit Secure Sockets Layer (SSL) Encryption</h2>

											<div class="testimonial-safe-body">
												<p>Tix employs 128 bit Secure Sockets Layer (SSL) Encryption to make sure that sensitive information is secure.</p>

											</div>
										</div>
									</div>
								</div>
							</div>

							<div class="testimonial-safe">
								<div class="container">
									<div class="row">
										<div class="col-md-12">
											<h2 class="title" style="text-transform: uppercase;">Visa Global Registry of Service Providers</h2>

											<div class="testimonial-safe-body">
												<p>Inclusion in Visa's Registry requires that Tix meet Visa's program requirements, rules and applicable PCI requirements.</p>

											</div>
										</div>
									</div>
								</div>
							</div>

							<div class="testimonial-safe">
								<div class="container">
									<div class="row">
										<div class="col-md-12">
											<h2 class="title" style="text-transform: uppercase;">Credit Card Number Storage</h2>

											<div class="testimonial-safe-body">
												<p>Tix does not store full credit card numbers. We only store the last four digits of the credit card for reference. This means that even if a hacker could gain unauthorized access to our system, there wouldn't be any valuable credit card information to steal.</p>

											</div>
										</div>
									</div>
								</div>
							</div>


							<div class="testimonial-safe">
								<div class="container">
									<div class="row">
										<div class="col-md-8 col-md-offset-2">
											<h2 class="title" style="text-transform: uppercase;">Nevada Gaming Commission</h2>

											<div class="testimonial-safe-body">
												<p>Tix is one of very few ticketing companies that have met the stringent requirements of the Nevada Gaming Commission for use in Nevada gaming establishments with entertainment venues and ticket sales.</p>

											</div>
										</div>
									</div>
								</div>
							</div>

						</div>

						<div style="text-align: center;">
							<img src="/Clients/TixNew/images/security1.png" border="0" style="display: inline-block;" />
						</div>

					</div>

				</div>
				<!-- section end -->

				<!-- PRICING START -->
				<div class="section">
					<div class="container">

						<br/>
						<h1 class="text-center space-top" id="pricing">Pricing</h1>
						<div class="separator"></div>
						<p class="lead text-center">
							No set up fees.  No monthly or annual fees.  No hidden fees.<br />
							No risk.
						</p>

						<div class="row">
							<div class="col-md-12">
								<div class="row">
									<div class="col-sm-4">
										<div class="box-style-1 default-bg object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="0">
											<ph1>$0.25</ph1>
											<p>Per Ticket</p>
											<h2>Box Office Fee</h2>
											<p>Tickets sold by your organization through the box office system. (Walk-up sales, etc.)</p>
											<i class="fa fa-user"></i>
										</div>
									</div>
									<div class="col-sm-4">
										<div class="box-style-1 default-bg object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="200">
											<ph1>$1.50</ph1>
											<p>Per Ticket</p>
											<h2>Online Fee</h2>
											<p>Tickets sold online, on kiosks and through mobile devices.</p>
											<i class="fa fa-desktop"></i>
										</div>
									</div>
									<div class="col-sm-4">
										<div class="box-style-1 default-bg object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="400">
											<ph1>$3.50</ph1>
											<p>Per Ticket</p>
											<h2>Call Center Fee</h2>
											<p>Ticket sold through our optional 24 hour, 7 day a week call center service.</p>
											<i class="fa fa-phone"></i>
										</div>
									</div>
								</div>
							</div>
						</div>

					</div>
				</div>

				<div class="container">
					<div class="row">
						<div class="col-md-12">
							<div class="row grid-space-20">
								<div class="col-sm-6">
									<div class="box-style-3 left object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="0">

										<div class="body">
											<h2>Merchant Account Flexibility</h2>
											<p>We offer two ways to process credit cards through our ticketing system. You can either use your merchant account, or ours. In order to use your own merchant account, it must include a compatible e-commerce payment gateway. Tix is compatible with over 30 different e-commerce payment gateways including Authorize.net, Cybersource, Global Gateway, Virtual Merchant, Stripe, PayPal and many more. </p>

										</div>
									</div>
									<div class="box-style-3 left object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="200">
										<div>
										</div>
										<div class="body">
											<h2>Credit Card Processing</h2>
											<p>If you wish to use the Tix merchant account we charge an additional fee of 5% of the ticket price for credit card processing. Tix does not charge an additional fee if you use your own merchant account.</p>


										</div>
									</div>
									<div class="box-style-3 left object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="400">
										<div>
										</div>
										<div class="body">
											<h2>Payment Schedule</h2>
											<p>When using your merchant account for credit card processing, ticket revenue goes directly into your account within 48-72 hours after each ticket purchase. We then invoice you for our fees. When using our merchant account for credit card processing, we send you a check the week after the event. </p>

										</div>
									</div>
								</div>
								<div class="col-sm-6">
									<div class="box-style-3 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="0">
										<div>
										</div>
										<div class="body">
											<h2>Set Your Own Fees</h2>
											<p>All of our fees can be passed along to the ticket buyer. This enables your organization to use our service at no cost. You may also include some, or all, of our fees into the ticket price. It's up to you. </p>

										</div>
									</div>
									<div class="box-style-3 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="200">
										<div>
										</div>
										<div class="body">
											<h2>Ticket Printing & Mailing</h2>
											<p>Tix can print and mail tickets directly to your ticket buyers. There is a single $3.00 shipping and handling fee applied to each order when we print and mail tickets for you. We can also print tickets and mail them directly to you for $.20 per ticket plus shipping. There are no shipping and handling fees applied to Will Call orders or orders in which we do not print and/or mail the tickets. </p>

										</div>
									</div>
									<div class="box-style-3 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="400">
										<div>
										</div>
										<div class="body">
											<h2>Low, Low Service Fees</h2>
											<p>Our service fees remain among the lowest in the ticketing industry.  Pass those savings along to your patrons and watch your ticket sales increase!</p>

										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>

				<div class="space"></div>

				<!-- PRICING END -->

				<!-- SERVE START -->
				<div class="section gray-bg clearfix">

					<div class="container">

						<br/>

						<h1 class="text-center space-top" id="serve">Who We Serve</h1>
						<div class="separator"></div>
						<p class="lead text-center">
							We specialize in feature-rich ticketing solutions for venues, promoters, producers, universities, theme parks, tours, museums, casinos, theatres, film festivals, concerts, night clubs, music festivals, race tracks, and more.</p>
							<br/>
							<div class="row">
								<div class="col-md-12">

									<!-- boxes end -->
									<div class="row grid-space-10">
										<div class="col-sm-4">
											<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="0">
												<div class="icon-container default-bg">
													<i class="icon-masks"></i>
												</div>
												<div class="body">
													<h2>Performing Arts</h2>
													<ul class="list-icons">
														<li>Reserved seating with multiple price tiers</li>
														<li>Season subscriptions and packages</li>
														<li>CRM and email marketing</li>

													</ul>
												</div>
											</div>
										</div>
										<div class="col-sm-4">
											<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="200">
												<div class="icon-container default-bg">
													<i class="fa fa-university"></i>
												</div>
												<div class="body">
													<h2>Colleges and Universities</h2>
													<ul class="list-icons">
														<li>CashNET and TouchNet ready</li>
														<li>Usable across multiple departments</li>
														<li>Student ID validation possible</li>

													</ul>
												</div>
											</div>
										</div>
										<div class="col-sm-4">
											<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="400">
												<div class="icon-container default-bg">
													<i class="fa fa-trophy"></i>
												</div>
												<div class="body">
													<h2>Sporting Events</h2>
													<ul class="list-icons">
														<li>Photographic seat views</li>
														<li>Season tickets and same-seat renewals</li>
														<li>Group rates and discounts</li>

													</ul>
												</div>
											</div>
										</div>
									</div>
									<div class="row grid-space-10">
										<div class="col-sm-4">
											<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="600">
												<div class="icon-container default-bg">
													<i class="fa fa-star-o"></i>
												</div>
												<div class="body">
													<h2>Dance Schools</h2>
													<ul class="list-icons">
														<li>Early event access for specific patrons</li>
														<li>Customer-specific promotional codes</li>
														<li>Real-time discount code tracking</li>

													</ul>
												</div>
											</div>
										</div>
										<div class="col-sm-4">
											<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="800">
												<div class="icon-container default-bg">
													<i class="icon-guitar"></i>
												</div>
												<div class="body">
													<h2>Live Music Venues</h2>
													<ul class="list-icons">
														<li>E-tickets and barcode scanning</li>
														<li>Multi-day and single day passes</li>
														<li>Pre-sale codes</li>

													</ul>
												</div>
											</div>
										</div>
										<div class="col-sm-4">
											<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="1000">
												<div class="icon-container default-bg">
													<i class="icon-card"></i>
												</div>
												<div class="body">
													<h2>Casinos</h2>
													<ul class="list-icons">
														<li>Nevada Gaming Commission approved</li>
														<li>Customer classifications</li>
														<li>Add-ons/Upsells</li>

													</ul>
												</div>
											</div>
										</div>
									</div>
									<div class="row grid-space-10">
										<div class="col-sm-4">
											<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="600">
												<div class="icon-container default-bg">
													<i class="fa fa-film"></i>
												</div>
												<div class="body">
													<h2>Film Festivals</h2>
													<ul class="list-icons">
														<li>Member discounts</li>
														<li>Festival passes and packages</li>
														<li>Social media tie-ins</li>

													</ul>
												</div>
											</div>
										</div>
										<div class="col-sm-4">
											<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="800">
												<div class="icon-container default-bg">
													<i class="fa fa-calendar"></i>
												</div>
												<div class="body">
													<h2>Tours</h2>
													<ul class="list-icons">
														<li>Calendar schedule display</li>
														<li>Mobile optimized purchasing</li>
														<li>Sell tickets from tablet</li>

													</ul>
												</div>
											</div>
										</div>
										<div class="col-sm-4">
											<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="1000">
												<div class="icon-container default-bg">
													<i class="fa fa-heart"></i>
												</div>
												<div class="body">
													<h2>Non-Profits</h2>
													<ul class="list-icons">
														<li>Donations and memberships</li>
														<li>Customized surveys</li>
														<li>Email Marketing</li>

													</ul>
												</div>
											</div>
										</div>
									</div>

									<div class="row grid-space-10">
										<div class="col-sm-4">
											<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="600">
												<div class="icon-container default-bg">
													<i class="icon-museum"></i>
												</div>
												<div class="body">
													<h2>Museums</h2>
													<ul class="list-icons">
														<li>Timed admissions</li>
														<li>Member discounts</li>
														<li>Special event access</li>

													</ul>
												</div>
											</div>
										</div>
										<div class="col-sm-4">
											<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="800">
												<div class="icon-container default-bg">
													<i class="fa fa-mortar-board"></i>
												</div>
												<div class="body">
													<h2>High Schools</h2>
													<ul class="list-icons">
														<li>Reserved seating</li>
														<li>Student ticket discounts</li>
														<li>Accept cash or check</li>

													</ul>
												</div>
											</div>
										</div>
										<div class="col-sm-4">
											<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="1000">
												<div class="icon-container default-bg">
													<i class="icon-peace"></i>
												</div>
												<div class="body">
													<h2>Religious Organizations</h2>
													<ul class="list-icons">
														<li>Donation solicitations</li>
														<li>Process box office sales on-site</li>
														<li>Call center service</li>

													</ul>
												</div>
											</div>
										</div>
									</div>

									<div class="row grid-space-10">
										<div class="col-sm-4">
											<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="600">
												<div class="icon-container default-bg">
													<i class="icon-tents"></i>
												</div>
												<div class="body">
													<h2>Fairs and Festivals</h2>
													<ul class="list-icons">
														<li>Gate admissions</li>
														<li>Concert tickets</li>
														<li>Group discounts</li>

													</ul>
												</div>
											</div>
										</div>
										<div class="col-sm-4">
											<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="800">
												<div class="icon-container default-bg">
													<i class="fa fa-music"></i>
												</div>
												<div class="body">
													<h2>Promoters</h2>
													<ul class="list-icons">
														<li>Unlimited venues</li>
														<li>Sell tickets from your iPhone or iPad</li>
														<li>Real-time settlement reporting</li>

													</ul>
												</div>
											</div>
										</div>
										<div class="col-sm-4">
											<div class="box-style-2 object-non-visible" data-animation-effect="fadeInUpSmall" data-effect-delay="1000">
												<div class="icon-container default-bg">
													<i class="icon-badge"></i>
												</div>
												<div class="body">
													<h2>Trade Shows/Exhibits</h2>
													<ul class="list-icons">
														<li>Sign-Ups and registrations</li>
														<li>Collect information for each attendee</li>
														<li>Sell display booths and spaces</li>

													</ul>
												</div>
											</div>
										</div>
									</div>

									<!-- boxes end -->

									<h3 class="text-center dark space-top">...and many more!</h3>

								</div>
							</div>

					</div>
				</div>

				<!-- SERVE END -->

				<!-- INFORMATION REQUEST START -->
				<div class="section parallax parallax-bg-2 dark-translucent-bg">

					<div class="container">

						<div class="row">
							<div class="col-md-8 col-md-offset-2">
								<div class="call-to-action">

									<h1 class="text-center space-top" id="start">Free Set Up</h1>

									<p>Join thousands of venues, promoters, and producers who have made Tix their complete box office and online ticketing solution.</p>

									<a id="btnGetStarted" href="" class="btn btn-demo openModal" data-toggle="modal" data-id="priority1" data-target="#emailModal" >Get Started</a>

									<br/>
									<p>Not quite ready yet? Contact us to <a id="lnkLearnMore" href="" class="openModal" data-toggle="modal" data-id="priority2" data-target="#emailModal">learn more</a>.</p>

								</div>
							</div>
						</div>

						<div class="modal fade" id="emailModal" tabindex="-1" role="dialog">

							<div class="modal-dialog">

								<div class="modal-content">

									<div class="modal-header bg-primary">
										<button type="button" class="close" data-dismiss="modal" aria-hidden="true" style="color: #ffffff;">
											<i class="fa fa-times-circle" style="color: #000000;"></i>
										</button>
										<h4 class="modal-title" style="color: #ffffff;">
											<span class="fa-stack fa-lg"><i class="fa fa-circle fa-stack-2x"></i><i class="text-default fa fa-envelope fa-stack-1x"></i></span>
											<span class="priority1Item">Get Started</span>
											<span class="priority2Item">Learn More</span>
											<span class="priority3Item">Free Demo</span>
										</h4>
									</div>

									<div class="modal-body">

										<div class="form-horizontal" id="formCustomerInfor">

											<span class="priority1Item">
												<b>Start selling tickets today!</b><br />
												Give us a call at (800) 504-4849 or enter your contact information below and we will contact you shortly.<br /><br />
												If you are interested in purchasing tickets, <a class="formSearchLink" href="search.aspx">click here.</a><br />
                                                If you have a question about ticket you purchased, <a class="formCustomerServiceLink" href="mailto://customerservice@tix.com">click here.</a><br /><br />
											</span>

											<span class="priority2Item">
												<b>Learn more today!</b><br />
												Give us a call at (800) 504-4849 or enter your contact information below and we will contact you shortly to answer any question you may have about using our system.<br /><br />
												If you are interested in purchasing tickets, <a class="formSearchLink" href="search.aspx">click here.</a><br />
                                                If you have a question about ticket you purchased, <a class="formCustomerServiceLink" href="mailto://customerservice@tix.com">click here.</a><br /><br />
											</span>

											<span class="priority3Item">
												<b>Free Demo!</b><br />
												Give us a call at (800) 504-4849 or enter your contact information below and we will contact you shortly to schedule a free demo of our system.<br /><br />
												If you are interested in purchasing tickets, <a class="formSearchLink" href="search.aspx">click here.</a><br />
                                                If you have a question about ticket you purchased, <a class="formCustomerServiceLink" href="mailto://customerservice@tix.com">click here.</a><br /><br />
											</span>

											<!-- do not display priority ID
													<div class="form-group">
														<label class="control-label col-md-4" for="priorityID">PriorityID</label>
														<div class="col-md-6 input-group">
															<input type="text" class="form-control" name="priorityID" id="priorityID" />
														</div>
													</div>
												-->

											<input type="hidden" name="PriorityID" id="PriorityID" />

											<div class="form-group">
												<label class="control-label col-md-4" for="FirstName">First Name <span style="color: red;">*</span></label>
												<div class="col-md-6 input-group required">
													<input type="text" class="form-control" name="FirstName" id="FirstName" placeholder="First Name" onfocus="this.placeholder = ''" onblur="this.placeholder = 'First Name'" maxlength="50" required />
												</div>
											</div>

											<div class="form-group">
												<label class="control-label col-md-4" for="LastName">Last Name <span style="color: red;">*</span></label>
												<div class="col-md-6 input-group required">
													<input type="text" class="form-control" name="LastName" id="LastName" placeholder="Last Name" onfocus="this.placeholder = ''" onblur="this.placeholder = 'Last Name'" maxlength="50" required />
												</div>
											</div>

											<div class="form-group">
												<label class="control-label col-md-4" for="Email">Email Address <span style="color: red;">*</span></label>
												<div class="col-md-6 input-group required">
													<input type="email" class="form-control" name="EMailAddress" placeholder="Email Address" onfocus="this.placeholder = ''" onblur="this.placeholder = 'Email Address'" maxlength="100" required />
												</div>
											</div>

											<div class="form-group">
												<label class="control-label col-md-4" for="Phone">Phone Number <span style="color: red;">*</span></label>
												<div class="col-md-6 input-group required">
													<input type="text" class="form-control" name="PhoneNumber" placeholder="Phone Number" onfocus="this.placeholder = ''" onblur="this.placeholder = 'Phone Number'" maxlength="20" required />
												</div>
											</div>

											<div class="form-group">
												<label class="control-label col-md-4" for="Organization">Organization Name</label>
												<div class="col-md-6 input-group">
													<input type="text" class="form-control" name="Organization" placeholder="Your Organization Name" onfocus="this.placeholder = ''" onblur="this.placeholder = 'Your Organization Name'" maxlength="200" />
												</div>
											</div>

											<!-- Alternate Form Field -->
											<div class="form-group fieldAlt">
												<label class="control-label col-md-4" for="OrganizationTypeOther">Other Organization</label>
												<div class="col-md-6 input-group">
													<input type="text" class="form-control" placeholder="Other Organization" name="OrganizationTypeOther" onfocus="this.placeholder = ''" onblur="this.placeholder ='OrganizationTypeOther'" />
												</div>
											</div>

											<!-- Additional priority2 Question -->
											<div class="form-group priority2Item">
												<label class="control-label col-md-4" for="addQuestion">Do you have a specific area of interest?</label>
												<div class="col-md-6 input-group">
													<textarea class="form-control" name="addQuestion" id="addQuestion" rows="3"></textarea>
												</div>
											</div>

											<div class="form-group">
												<label class="control-label col-md-4" for="Email"><span style="color: red;">* Required Field</span></label>
												<div class="col-md-6 input-group required">
												</div>
											</div>

											<div class="clearfix"></div>

										</div>

									</div>

									<div class="modal-footer" style="background-color: #f1f1f1">

										<div class="form-group actions">
											<label class="control-label col-md-4" for="Other"></label>
											<div class="col-md-6 input-group">
												<button type="button" id="btnEmail" class="btn btn-confirm">Submit</button>
											</div>
										</div>

									</div>

								</div>

							</div>

						</div>

					</div>

				</div>
				<!-- INFORMATION REQUEST END -->

			</section>
			<!-- MAIN SECTION END -->


			<!-- footer start (Add "light" class to #footer in order to enable light footer) -->
			<!-- ================ -->
			<footer id="footer">

				<!-- .footer start -->
				<!-- ================ -->
				<div class="footer">
					<div class="container">
						<div class="row">
							<div class="col-md-6">
								<div class="footer-content">
									<div class="logo-footer"></div>
									<div class="row">
										<div class="col-sm-6">
											<p>
												Integrated box office and online ticketing solutions for thousands of organizations like yours.<br />
											</p>
											<a id="footerCapterra" href="http://www.capterra.com/ticketing-software/reviews/9322/Tix/Tix" target="_capterra" title="Tix -  5.0 out of 5 stars - 21 reviews">
												<img src="https://assets.capterra.com/badge/122f66800f163085bc146c1bb1fbe362.png?v=2002671&p=9322" border="0" /></a>

										</div>
										<div class="col-sm-6">
											<ul class="list-icons">
												<li><i class="fa fa-map-marker pr-10"></i>718 W. Anaheim Street<br />
													Long Beach, CA 90813</li>
												<li><i class="fa fa-phone pr-10"></i>800.504.4849 </li>
												<li><i class="fa fa-fax pr-10"></i>562.951.1463 </li>
												<li><i class="fa fa-envelope-o pr-10"></i><a id="footerEmailTix" href="mailto:info@tix.com">info@tix.com</a></li>
<br>
                        <p style="word-break: keep-all;"> <strong>Need Order Help?</strong><BR><a href="mailto:customerservice@tix.com">customerservice@tix.com</a></p>
												<ul class="social-links circle">
													<li class="facebook"><a id="footerFacebook" target="_blank" href="https://www.facebook.com/pages/Tix/94873447107"><i class="fa fa-facebook"></i></a></li>
													<li class="twitter"><a id="footerTwitter" target="_blank" href="http://www.twitter.com/TixInc"><i class="fa fa-twitter"></i></a></li>
													<li class="googleplus"><a id="footerGoogle" target="_blank" href="http://plus.google.com/106184051327532678900/about"><i class="fa fa-google-plus"></i></a></li>
												</ul>

											</ul>

										</div>
									</div>

								</div>
							</div>
							<div class="space-bottom hidden-lg hidden-xs"></div>
							<div class="col-sm-6 col-md-2">
								<div class="footer-content">
									<h3>Links</h3>
									<nav>
										<ul class="nav nav-pills nav-stacked">
											<li><a id="footerWhyTix" href="#why">Why Tix?</a></li>
											<li><a id="footerFeatures" href="#features">Features</a></li>
											<li><a id="footerPricing" href="#pricing">Pricing</a></li>
											<li><a id="footerWhoWeServe" href="#serve">Who We Serve</a></li>
											<li><a id="footerTixBlog" href="http://blog.tix.com">Tix Blog</a></li>
											<li><a id="footerTicketBuyerLogin" href="https://www.tix.com/secure/login.aspx">Ticket Buyer Login</a></li>
											<li><a id="footerTixClientLogin" href="https://www.tix.com/management">Tix Client Login</a></li>
										</ul>
									</nav>
								</div>
							</div>
							<div class="col-sm-6 col-md-3 col-md-offset-1">
								<div class="footer-content">
									<img id="LogoOnGray" src="/Clients/TixNew/images/TixLogoBGGray400x300R.png" alt="tix" />
								</div>
							</div>
						</div>
						<div class="space-bottom hidden-lg hidden-xs"></div>
					</div>
				</div>
				<!-- .footer end -->

				<!-- .subfooter start -->
				<!-- ================ -->
				<div class="subfooter">
					<div class="container">
						<div class="row">
							<div class="col-md-6">
								<p><a target="_blank" href="http://www.tix.com">Tix, Inc.</a> © 2001-2015 | All Rights Reserved</p>
							</div>
							<div class="col-md-6">
								<nav class="navbar navbar-default" role="navigation">
									<!-- Toggle get grouped for better mobile display -->
									<div class="navbar-header">
										<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navbar-collapse-2">
											<span class="sr-only">Toggle navigation</span>
											<span class="icon-bar"></span>
											<span class="icon-bar"></span>
											<span class="icon-bar"></span>
										</button>
									</div>
									<div class="collapse navbar-collapse" id="navbar-collapse-2">
										<ul class="nav navbar-nav">
											<li><a id="footerPrivacyPolicy" href="/privacy.html">Privacy Policy</a></li>
											<li><a id="footerTermsOfUse" href="/termsofuse.html">Terms of Use</a></li>

										</ul>
									</div>
								</nav>
							</div>
						</div>
					</div>
				</div>
				<!-- .subfooter end -->

			</footer>
			<!-- footer end -->

		</div>
		<!-- PAGE END -->

		<!-- JavaScript files placed at the end of the document so the pages load faster
		================================================== -->

		<!-- Modernizr javascript -->
		<script type="text/javascript" src="/Clients/TixNew/plugins/modernizr.js"></script>

		<!-- jQuery REVOLUTION Slider  -->
		<script type="text/javascript" src="/Clients/TixNew/plugins/rs-plugin/js/jquery.themepunch.tools.min.js"></script>
		<script type="text/javascript" src="/Clients/TixNew/plugins/rs-plugin/js/jquery.themepunch.revolution.min.js"></script>

		<!-- Isotope javascript -->
		<script type="text/javascript" src="/Clients/TixNew/plugins/isotope/isotope.pkgd.min.js"></script>

		<!-- Owl carousel javascript -->
		<script type="text/javascript" src="/Clients/TixNew/plugins/owl-carousel/owl.carousel.js"></script>

		<!-- Magnific Popup javascript -->
		<script type="text/javascript" src="/Clients/TixNew/plugins/magnific-popup/jquery.magnific-popup.min.js"></script>

		<!-- Appear javascript -->
		<script type="text/javascript" src="/Clients/TixNew/plugins/jquery.appear.js"></script>

		<!-- Count To javascript -->
		<script type="text/javascript" src="/Clients/TixNew/plugins/jquery.countTo.js"></script>

		<!-- Parallax javascript -->
		<script src="/Clients/TixNew/plugins/jquery.parallax-1.1.3.js"></script>

		<!-- Contact form -->
		<script src="/Clients/TixNew/plugins/jquery.validate.js"></script>

		<!-- Initialization of Plugins -->
		<script type="text/javascript" src="/Clients/TixNew/js/template.js"></script>
		<script src="/Clients/TixNew/bootstrap/js/sweet-alert.min.js"></script>

		<script type="text/javascript">

		    (function ($) {
		        $.fn.serializeFormJSON = function () {
		            var o = {};
		            var a = this.serializeArray();
		            $.each(a, function () {
		                if (o[this.name]) {
		                    if (!o[this.name].push) {
		                        o[this.name] = [o[this.name]];
		                    }
		                    o[this.name].push(this.value || '');
		                } else {
		                    o[this.name] = this.value || '';
		                }
		            });
		            return o;
		        };
		    })(jQuery);

		    //Information Request Modal
		    $(function () {

		        //remove button focus after it's been clicked
		        $(".btn").mouseup(function () {
		            $(this).blur();
		        })

		        //hide the "Organization Type - Other" field
		        $(".fieldAlt").hide();

		        //hide priority 1 items
		        $(".priority1Item").hide();

		        //hide priority 2 items
		        $(".priority2Item").hide();

		        //disable the submit button until all required fields are filled out
		        $('#btnEmail').attr('disabled', 'disabled');

		        //determine the priority ID based on which link is clicked
		        $(document).on("click", ".openModal", function () {
		            var requestID = $(this).data('id');

		            //add priority ID to form
		            $(".modal-body #PriorityID").val(requestID);

		            //display appropriate priority ID items
		            if (requestID == 'priority1') {
		                $(".priority1Item").show();
		                $(".priority2Item").hide();
		                $(".priority3Item").hide();
		            } else if (requestID == 'priority2') {
		                $(".priority2Item").show();
		                $(".priority1Item").hide();
		                $(".priority3Item").hide();
		            } else if (requestID == 'priority3') {
		                $(".priority3Item").show();
		                $(".priority2Item").hide();
		                $(".priority1Item").hide();
		            }

		        });

		        //modal window display
		        $('#emailModal').on('show.bs.modal', function (e) {

		            //display the "Other" field when "Organization Type - Other" answer is selected
		            $('select#OrganizationType').on('change', function () {
		                if ($("#OrganizationType").val() == 'Other')
		                    $(".fieldAlt").fadeIn('slow');
		                else
		                    $(".fieldAlt").fadeOut('slow');
		            });

		            //enable submit button once required fields are filled out
		            $('.required input').keyup(function () {
		                var empty = false;
		                $('.required input').each(function () {
		                    if ($(this).val().length == 0) {
		                        empty = true;
		                    }
		                });
		                if (empty) {
		                    $('#btnEmail').attr('disabled', 'disabled');
		                } else {
		                    $('#btnEmail').attr('disabled', false);
		                }
		            });
		        });

		        //process the email when submit button is clicked.
		        $('#btnEmail').click(function () {
		            var userName = $("#FirstName").val();
		            var formJson = $("#formCustomerInfor :input").serializeFormJSON();
		            var data = $("#formCustomerInfor :input").serialize();

		            $.ajax({
		                type: "POST",
		                url: "Default.aspx/InsertInvitationRequest",
		                data: '{"customerInfo": ' + JSON.stringify(formJson) + '}',
		                contentType: "application/json; charset=utf-8",
		                dataType: "json"
		            })
					//success! no errors
					.done(function (data) {

						//loop through each field and clear it out
						$("#formCustomerInfor :input").each(function()
						{
							$(this).val('');
						});
						$("#OrganizationType").val('None');
						$(".fieldAlt").hide();
						$(".modal-body #PriorityID").val('priority1'); //close other text box

					    $('#btnEmail').attr('disabled', 'disabled');

					    //remove modal window
					    $(".modal").modal('hide');

					    //display success notification
					    $(".modal").one('hidden.bs.modal', function () {
					        swal(
							{
							    title: 'Thank You, ' + userName + '!',
							    text: data.d,
							    type: "success",
							    showCancelButton: false,
							    confirmButtonClass: "btn-confirm",
							    confirmButtonText: "OK",
							    html: true,
							    timer: 20000

							});
					        ga('send', 'event', 'InfoRequest', 'click', 'Submitted');
					    });
					})
					//darn! something went wrong
					.error(function (data) {
					    //remove modal window
					    $(".modal").modal('hide');

					    $(".modal").one('hidden.bs.modal', function () {
					        swal(
							{
							    title: 'Sorry',
							    text: "There was a problem. Please contact TIX!",
							    type: "error",
							    showCancelButton: false,
							    confirmButtonClass: "btn-confirm",
							    confirmButtonText: "OK",
							    html: true,
							    timer: 20000

							});
					        ga('send', 'event', 'button', 'click', 'Info Request Error');
					    });
					});
		            capterraTracking();
		        });
		    });

		</script>
	</form>

</body>
</html>

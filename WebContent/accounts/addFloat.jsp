<!DOCTYPE html>
<%--
  Copyright (c) impalapay Ltd., June 23, 2014

  @author eugene chimita, eugenechimita@impalapay.com
--%>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.pagination.mainfloat.MainfloatPage"%>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.pagination.mainfloat.MainfloatPaginator"%>
<%@ page import="com.impalapay.airtel.beans.accountmgmt.balance.MasterAccountFloatPurchase"%>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.pagination.floatbycountry.MainfloatPerCountryPage"%>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.pagination.floatbycountry.MainfloatPerCountryPaginator"%>
<%@ page import="com.impalapay.airtel.beans.accountmgmt.balance.AccountPurchaseByCountry"%>
<%@ page import="com.impalapay.airtel.beans.geolocation.Country" %>
<%@ page import="com.impalapay.airtel.beans.accountmgmt.Account" %>
<%@ page import="com.impalapay.airtel.beans.accountmgmt.AccountStatus" %>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.SessionConstants" %>
<%@ page import="com.impalapay.airtel.accountmgmt.session.SessionStatistics"%>
<%@ page import="com.impalapay.airtel.persistence.accountmgmt.AccountStatusDAO" %>
<%@ page import="com.impalapay.airtel.cache.CacheVariables"%>

<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Collections"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Iterator"%>

<%@ page import="net.sf.ehcache.Cache" %>
<%@ page import="net.sf.ehcache.CacheManager" %>
<%@ page import="net.sf.ehcache.Element"%>

<%
    // The following is for session management.
    if (session == null) {
        response.sendRedirect("../index.jsp");
    }

    String sessionKey = (String) session.getAttribute(SessionConstants.ADMIN_SESSION_KEY);

    if (StringUtils.isEmpty(sessionKey)) {
        response.sendRedirect("../index.jsp");
    }

    session.setMaxInactiveInterval(SessionConstants.SESSION_TIMEOUT);
    response.setHeader("Refresh", SessionConstants.SESSION_TIMEOUT + "; url=../logout");
    // End of session management code




    CacheManager mgr = CacheManager.getInstance();
    Cache accountsCache = mgr.getCache(CacheVariables.CACHE_ACCOUNTS_BY_UUID);
    Cache countryCache = mgr.getCache(CacheVariables.CACHE_COUNTRY_BY_UUID);

    // This HashMap contains the UUIDs of countries as keys and the country names as values
    HashMap<String, String> countryHash = new HashMap<String, String>();
    HashMap<String, String> countrycurrencyHash = new HashMap<String, String>();
    HashMap<String, String> accountHash = new HashMap<String, String>();

    Cache statisticsCache = mgr.getCache(CacheVariables.CACHE_ALL_ACCOUNTS_STATISTICS);

    List keys;

    Element element;
    Country country;
    Account account;

    List<Account> accountList = new ArrayList<Account>();
    List<MasterAccountFloatPurchase> mainfloatList;
    List<AccountPurchaseByCountry> mainfloatpercountryList;

    keys = accountsCache.getKeysWithExpiryCheck();
    for (Object key : keys) {
        if ((element = accountsCache.get(key)) != null) {
            accountList.add((Account) element.getObjectValue());
        }
    }

    keys = countryCache.getKeys();
    for (Object key : keys) {
        element = countryCache.get(key);
        country = (Country) element.getObjectValue();
        countryHash.put(country.getUuid(), country.getName());
    }

    keys = countryCache.getKeys();
    for (Object key : keys) {
        element = countryCache.get(key);
        country = (Country) element.getObjectValue();
        countrycurrencyHash.put(country.getUuid(), country.getCurrency());
    }

    keys = accountsCache.getKeys();
    for (Object key : keys) {
        element = accountsCache.get(key);
        account = (Account) element.getObjectValue();
        accountHash.put(account.getUuid(), account.getFirstName());
    }

    Calendar calendar = Calendar.getInstance();

    final int DAYS_IN_MONTH = calendar.getActualMaximum(Calendar.DAY_OF_MONTH) + 1;
    final int DAY_OF_MONTH = calendar.get(Calendar.DAY_OF_MONTH);
    final int MONTH = calendar.get(Calendar.MONTH) + 1;
    final int YEAR = calendar.get(Calendar.YEAR);
    final int YEAR_COUNT = YEAR + 10;

    int count = 0;  // A generic counter
    int incount = 0;  // Generic counter
    int incounts = 0;

    MainfloatPaginator paginator = new MainfloatPaginator();
    MainfloatPerCountryPaginator paginators = new MainfloatPerCountryPaginator();

    SessionStatistics statistics = new SessionStatistics();

     if ((element = statisticsCache.get(CacheVariables.CACHE_ALL_ACCOUNTS_STATISTICS_KEY)) != null) {
        statistics = (SessionStatistics) element.getObjectValue();
    }

    incount = statistics.getMainfloatCountTotal();
    MainfloatPage mainfloatPage;
    int mainfloatCount = 0; // The current count of the Accounts sessions

    if (incount == 0) { 	// This user has no Incoming USSD in the account
        mainfloatPage = new MainfloatPage();
        mainfloatList = new ArrayList<MasterAccountFloatPurchase>();
        mainfloatCount = 0;

    } else {
        mainfloatPage = (MainfloatPage) session.getAttribute("currentadminMainfloatPage");
        String referrer = request.getHeader("referer");
        String pageParam = (String) request.getParameter("page");

        // We are to give the first page
        if (mainfloatPage == null
                || !StringUtils.endsWith(referrer, "addFloat.jsp")
                || StringUtils.equalsIgnoreCase(pageParam, "first")) {
            mainfloatPage = paginator.getFirstPage();

            // We are to give the last page
        } else if (StringUtils.equalsIgnoreCase(pageParam, "last")) {
            mainfloatPage = paginator.getLastPage();

            // We are to give the previous page
        } else if (StringUtils.equalsIgnoreCase(pageParam, "previous")) {
            mainfloatPage = paginator.getPrevPage(mainfloatPage);

            // We are to give the next page
        } else {
            mainfloatPage = paginator.getNextPage(mainfloatPage);
        }

        session.setAttribute("currentadminMainfloatPage", mainfloatPage);

        mainfloatList = mainfloatPage.getContents();

        mainfloatCount = (mainfloatPage.getPageNum() - 1) * mainfloatPage.getPagesize() + 1;


    }

    incounts = statistics.getMainfloatbycountryCountTotal();
    MainfloatPerCountryPage mainfloatpercountryPage;
    int mainfloatpercountryCount = 0; // The current count of the Accounts sessions

    if (incounts == 0) { 	// This user has no Incoming USSD in the account
        mainfloatpercountryPage = new MainfloatPerCountryPage();
        mainfloatpercountryList = new ArrayList<AccountPurchaseByCountry>();
        mainfloatpercountryCount = 0;

    } else {
        mainfloatpercountryPage = (MainfloatPerCountryPage) session.getAttribute("currentMainfloatPerCountryPage");
        String referrers = request.getHeader("referer");
        String pageParams = (String) request.getParameter("page");

        // We are to give the first page
        if (mainfloatpercountryPage == null
                || !StringUtils.endsWith(referrers, "addFloat.jsp")
                || StringUtils.equalsIgnoreCase(pageParams, "first")) {
            mainfloatpercountryPage = paginators.getFirstPage();

            // We are to give the last page
        } else if (StringUtils.equalsIgnoreCase(pageParams, "last")) {
            mainfloatpercountryPage = paginators.getLastPage();

            // We are to give the previous page
        } else if (StringUtils.equalsIgnoreCase(pageParams, "previous")) {
            mainfloatpercountryPage = paginators.getPrevPage(mainfloatpercountryPage);

            // We are to give the next page
        } else {
            mainfloatpercountryPage = paginators.getNextPage(mainfloatpercountryPage);
        }

        session.setAttribute("currentMainfloatPerCountryPage", mainfloatpercountryPage);

        mainfloatpercountryList = mainfloatpercountryPage.getContents();

        mainfloatpercountryCount = (mainfloatpercountryPage.getPageNum() - 1) * mainfloatpercountryPage.getPagesize() + 1;


    }


%>
<html lang="en">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <!-- Meta, title, CSS, favicons, etc. -->
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>ImpalaPay | Add Float</title>
    <link  rel="icon" type="image/png"  href="../images/logo.jpg">

    <!-- Bootstrap core CSS -->

    <link href="../css/bootstrap.min.css" rel="stylesheet">

    <link href="../fonts/css/font-awesome.min.css" rel="stylesheet">
    <link href="../css/animate.min.css" rel="stylesheet">

    <!-- Custom styling plus plugins -->
    <link href="../css/custom.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="../css/maps/jquery-jvectormap-2.0.1.css" />
    <link href="../css/icheck/flat/green.css" rel="stylesheet">
    <link href="../css/floatexamples.css" rel="stylesheet" />

    <script src="../js/jquery.min.js"></script>

    <!--[if lt IE 9]>
        <script src="../assets/js/ie8-responsive-file-warning.js"></script>
        <![endif]-->

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
          <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
          <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
        <![endif]-->

</head>


<body class="nav-md">

    <div class="container body">


        <div class="main_container">

            <div class="col-md-3 left_col">
                <div class="left_col scroll-view">


                    <div class="clearfix"></div>

                    <!-- menu prile quick info -->
                    <div class="profile">
                        <div class="profile_pic">
                            <img src="../images/img.png" alt="..." class="img-circle profile_img">
                        </div>
                        <div class="profile_info">
                            <span>Welcome,</span>
                            <h2><%=sessionKey%></h2>
                        </div>
                    </div>
                    <!-- /menu prile quick info -->

                    <br />

<!-- sidebar menu -->
<div id="sidebar-menu" class="main_menu_side hidden-print main_menu">

<div class="menu_section">

<ul class="nav side-menu">
<li><a><i class="fa fa-area-chart"></i> Home <span class="fa fa-chevron-down"></span></a>
<ul class="nav child_menu" style="display: none">
    <li><a href="../dashboard.jsp">Dashboard</a>
    </li>
    </li>
</ul>
</li>
<li><a><i class="fa fa-users"></i>Personal<span class="fa fa-chevron-down"></span></a>
<ul class="nav child_menu" style="display: none">
    <li><a href="profile.jsp">Profile</a>
    </li>
      <li><a href="changepassword.jsp">Change Password</a>
    </li>
     <li><a href="emailnotify.jsp">Email Notification</a>
    </li>
</ul>
</li>
<li><a><i class="fa fa-users"></i>Accounts<span class="fa fa-chevron-down"></span></a>
<ul class="nav child_menu" style="display: none">
    <li><a href="currencies.jsp">Manage Currencies</a>
    </li>
      <li><a href="addManagementAccount.jsp">Manage Accounts</a>
    </li>
     <li><a href="systemaccounts.jsp">System Accounts</a>
    </li>
    <li><a href="schedulepayments.jsp">Schedule Payments</a>
    </li>
      <li><a href="systempayments.jsp">System Payments</a>
    </li>
     <li><a href="memberpayments.jsp">Member Payments</a>
    </li>
    </li>
     <li><a href="accountfees.jsp">Account Fees</a>
    </li>
    <li><a href="manageloans.jsp">Manage Loans</a>
    </li>
      <li><a href="loanpayment.jsp">Loan Payments</a>
    </li>

</ul>
</li>
<li><a><i class="fa fa-users"></i>User/UserGroup<span class="fa fa-chevron-down"></span></a>
<ul class="nav child_menu" style="display: none">
    <li><a href="accountsIndex.jsp">Manage Members</a>
    </li>
      <li><a href="bulkactions.jsp">Bulk Action</a>
    </li>
     <li><a href="importmembers.jsp">Import Members</a>
    </li>
    <li><a href="manageadmins.jsp">Manage Admins</a>
    </li>
      <li><a href="connectedusers.jsp">Connected Users</a>
    </li>
     <li><a href="pendingmembers.jsp">Pending Members</a>
    </li>
    <li><a href="registrationagreements.jsp">Registration Agreements</a>
    </li>
      <li><a href="permissiongroups.jsp">Permission Groups</a>
    </li>
     <li><a href="loangroups.jsp">Loan Groups</a>
    </li>
    <li><a href="memberrecords.jsp">Member Records Type</a>
    </li>
</ul>
</li>
<li><a><i class="fa fa-database"></i>Access Devices<span class="fa fa-chevron-down"></span></a>
<ul class="nav child_menu" style="display: none">
    <li><a href="alltransaction.jsp">View All Transactions</a>
    </li>
     <li><a href="updatestatus.jsp">Adjust Transaction Status</a>
    </li>
</ul>
</li>
<!--<li><a><i class="fa fa-money"></i>Manage Balance<span class="fa fa-chevron-down"></span></a>
<ul class="nav child_menu" style="display: none">
    <li><a href="accounts/addFloat.jsp">Adjust Client Balance</a>
    <li><a href="accounts/floatHistory.jsp">Client Balance History</a>
</ul>
</li>-->
<li><a><i class="fa fa-wifi"></i>Messages<span class="fa fa-chevron-down"></span></a>
<ul class="nav child_menu" style="display: none">
   <li><a href="addCountry.jsp">Add Country(MNO)</a></li>
    </li>
   <li><a href="addmnoprefix.jsp">Define Prefix(MNO)</a></li>
    </li>
     <li><a href="addNetwork.jsp">Add Networks</a></li>
    </li>
    <li><a href="addBank.jsp">Add Bank</a></li>
    </li>
</ul>
</li>
<li><a><i class="fa fa-exclamation-triangle"></i>Settings<span class="fa fa-chevron-down"></span></a>
<ul class="nav child_menu" style="display: none">
    <li><a href="addSessionIp.jsp">Local Setting</a>
    </li>
     <li><a href="systemlog.jsp">Alert Setting</a>
    </li>
    <li><a href="mailsettings.jsp">Mail Setting</a>
    </li>
     <li><a href="systemlog.jsp">Log Setting</a>
    </li>
    <li><a href="addSessionIp.jsp">Channels</a>
    </li>
     <li><a href="systemlog.jsp">WebServices Clients</a>
    </li>
    <li><a href="addSessionIp.jsp">System Tasks</a>
    </li>
</ul>
</li>
<li><a><i class="fa fa-exclamation-triangle"></i>Reports<span class="fa fa-chevron-down"></span></a>
<ul class="nav child_menu" style="display: none">
    <li><a href="addSessionIp.jsp">IP-WhiteList/Session-Url</a>
    </li>
     <li><a href="systemlog.jsp">SystemLog History</a>
    </li>
</ul>
</li>
</ul>
</div>

</div>
                    <!-- /menu footer buttons -->
                   <!-- <div class="sidebar-footer hidden-small">
                        <a data-toggle="tooltip" data-placement="top" title="Settings">
                            <span class="glyphicon glyphicon-cog" aria-hidden="true"></span>
                        </a>
                        <a data-toggle="tooltip" data-placement="top" title="FullScreen">
                            <span class="glyphicon glyphicon-fullscreen" aria-hidden="true"></span>
                        </a>
                        <a data-toggle="tooltip" data-placement="top" title="Lock">
                            <span class="glyphicon glyphicon-eye-close" aria-hidden="true"></span>
                        </a>
                        <a data-toggle="tooltip" data-placement="top" title="Logout">
                            <span class="glyphicon glyphicon-off" aria-hidden="true"></span>
                        </a>
                    </div>-->
                    <!-- /menu footer buttons -->
                </div>
            </div>

            <!-- top navigation -->
            <div class="top_nav">

                <div class="nav_menu">
                    <nav class="" role="navigation">
                        <div class="nav toggle">
                            <a id="menu_toggle"><i class="fa fa-bars"></i></a>
                        </div>

                        <ul class="nav navbar-nav navbar-right">
                            <li class="">
                                <a href="javascript:;" class="user-profile dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                    <img src="../images/img.png" alt=""><%= sessionKey%>
                                    <span class=" fa fa-angle-down"></span>
                                </a>
                                <ul class="dropdown-menu dropdown-usermenu animated fadeInDown pull-right">
                                    <li>
                                        <form name="logoutForm" method="post" action="../logout">
                                            <p>
                                            <!--<input type="submit" class="btn btn-primary" name="logout" id="logout" value="Logout">-->
                                            <button type="submit" class="btn btn-primary"><i class="fa fa-sign-out pull-right"></i> Log Out</button>

                                            </p>
                                        </form>

                                    </li>
                                </ul>
                            </li>
                        </ul>
                    </nav>
                </div>

            </div>
            <!-- /top navigation -->


            <!-- page content -->
        <div class="right_col" role="main">
            <div class="">
                                <div class="page-title">
                                    <div class="title_left">
                                        <h3>Float Management</h3>
                                    </div>
                                </div>



                                        <div class="row">
                        <div class="col-md-12">
                            <div class="x_panel">
                                <div class="x_content">

                                    <div class="row">

                                            <div class="col-lg-6 col-xs-6">
                                                <!-- small box -->
                                                <div class="small-box">
                                                    <div class="inner">

                                                    <div class="x_content">

                                                     </div>
                                                     <form id="userSecurityForm" class="form-horizontal" action="addMasterFloat" method="post">
                                                        <!--<div class="container">-->
                                                            <!--<div class="row">-->
                                                                <!--<div class="span4">-->
                                                                    <div class="alert alert-block alert-info">
                                                                    <p>
                                                                        ADD MASTER FLOAT
                                                                    </p>
                                                                    </div>
                                                                    <%
                                                                    String addMasterErr = (String) session.getAttribute(SessionConstants.ADMIN_ADD_MASTER_FLOAT_ERROR_KEY);
                                                                    String addMasterSuccess = (String) session.getAttribute(
                                                                            SessionConstants.ADMIN_ADD_MASTER_FLOAT_SUCCESS_KEY);
                                                                    HashMap<String, String> ParamHash = (HashMap<String, String>) session.getAttribute(
                                                                            SessionConstants.ADMIN_ADD_MASTER_FLOAT_PARAMETERS);

                                                                    if (ParamHash == null) {
                                                                        ParamHash = new HashMap<String, String>();
                                                                    }

                                                                    if (StringUtils.isNotEmpty(addMasterErr)) {
                                                                        out.println("<p class=\"alert alert-error\">");
                                                                        out.println("Form error: " + addMasterErr);
                                                                        out.println("</p>");
                                                                        session.setAttribute(SessionConstants.ADMIN_ADD_MASTER_FLOAT_ERROR_KEY, null);
                                                                    }

                                                                    if (StringUtils.isNotEmpty(addMasterSuccess)) {
                                                                        out.println("<p class=\"alert alert-success\">");
                                                                        out.println("You have successfully added float to the master float  account. You may add more below. "
                                                                                + "Please relogin to system to get an updated master float.");
                                                                        out.println("</p>");
                                                                        session.setAttribute(SessionConstants.ADMIN_ADD_MASTER_FLOAT_SUCCESS_KEY, null);
                                                                    }
                                                                     %>
                                                                    <fieldset>
                                                                 <div class="form-group">
                                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12">Account
                                                                        </label>
                                                                        <div class="col-md-7 col-sm-7 col-xs-12">
                                                                           <select name="accountUuid" id="input" class="form-control col-md-3 col-xs-12">
                                                                                <option value="">select Account from dropdown</option>
                                                                                    <%
                                                                                for (Account a : accountList) {
                                                                                    out.println("<option value=\"" + a.getUuid() + "\">"
                                                                                    + a.getFirstName() + " " + a.getLastName() + " " + a.getAccounttype() + "</option>");

                                                                                    }//end for (Account a : accountList)
                                                                                %>
                                                                                </select>
                                                                        </div>
                                                                     </div>

                                                                    <div class="form-group">
                                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12">Amount in Usd or Gbp
                                                                        </label>
                                                                        <div class="col-md-7 col-sm-7 col-xs-12">
                                                                          <input id="input" name="amount" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                                                               out.println("value=\"" + StringUtils.trimToEmpty(ParamHash.get("amount")) + "\"");
                                                                                 %> >
                                                                        </div>
                                                                     </div>
                                                                    <input type="hidden"  name="username"  					<%
                                           out.println("value=\"" + StringUtils.trimToEmpty(sessionKey) + "\"");
                                    %>>

                                                                        <div class="control-group ">

                                                                            <td><label class="control-label">Date&nbsp;</label></td>
                                                                            <div class="controls">
                                                                                <td><select name="addDay" id="input" class="span2">
                                                                                    <%
                                                                                        for (int j = 1; j < DAYS_IN_MONTH; j++) {
                                                                                            if (j == DAY_OF_MONTH) {
                                                                                                out.println("<option selected=\"selected\" value=\"" + j + "\">" + j + "</option>");
                                                                                            } else {
                                                                                                out.println("<option value=\"" + j + "\">" + j + "</option>");
                                                                                            }
                                                                                        }
                                                                                    %>
                                                                                 </select>-</td>
                                                                                <td> <select name="addMonth" id="input" class="span2">
                                                                                    <%
                                                                                        for (int j = 1; j < 13; j++) {
                                                                                            if (j == MONTH) {
                                                                                                out.println("<option selected=\"selected\" value=\"" + j + "\">" + j + "</option>");
                                                                                            } else {
                                                                                                out.println("<option value=\"" + j + "\">" + j + "</option>");
                                                                                            }
                                                                                        }
                                                                                     %>
                                                                                </select>-</td>
                                                                                <td> <select name="addYear" id="input" class="span2">
                                                                                    <%
                                                                                        for (int j = YEAR; j < YEAR_COUNT; j++) {
                                                                                            if (j == YEAR) {
                                                                                                out.println("<option selected=\"selected\" value=\"" + j + "\">" + j + "</option>");
                                                                                            } else {
                                                                                                out.println("<option value=\"" + j + "\">" + j + "</option>");
                                                                                            }
                                                                                        }
                                                                                    %>
                                                                                </select></td>
                                                                            </div>
                                                                        </div>
                                                                    </fieldset>
                                                                    <footer id="submit-actions" class="form-actions">
                                                                        <button id="submit-button" type="submit" class="btn btn-primary" name="action" value="CONFIRM">Add</button>
                                                                    </footer>
                                                                <!--</div>-->
                                                            <!--</div>-->
                                                        <!--</div>-->
                                                    </form>



                                                    </div>
                                                </div>
                                            </div><!-- ./col -->

                                            <div class="col-lg-6 col-xs-6">
                                                <!-- small box -->
                                                <div class="small-box">
                                                    <div class="inner">
                                                    <div class="x_content">
                                                    </div>
                                                         <form id="userSecurityForm" class="form-horizontal" action="addFloatPerCountry" method="post">
                                                        <!--<div class="container">-->
                                                            <!--<div class="row">-->
                                                                <!--<div class="span8">-->
                                                                    <div class="alert alert-block alert-info">
                                                                    <p>
                                                                       ADD FLOAT BY COUNTRY
                                                                    </p>
                                                                    </div>
                                                                   <%
                                                                        String addClientErr = (String) session.getAttribute(SessionConstants.ADMIN_ADD_COUNTRY_FLOAT_ERROR_KEY);
                                                                        String addClientSuccess = (String) session.getAttribute(
                                                                                SessionConstants.ADMIN_ADD_COUNTRY_FLOAT_SUCCESS_KEY);

                                                                        HashMap<String, String> CountryfloatparamHash = (HashMap<String, String>) session.getAttribute(
                                                                                SessionConstants.ADMIN_ADD_COUNTRY_FLOAT_PARAMETERS);

                                                                        if (CountryfloatparamHash == null) {
                                                                            CountryfloatparamHash = new HashMap<String, String>();
                                                                        }

                                                                        if (StringUtils.isNotEmpty(addClientErr)) {
                                                                            out.println("<p class=\"alert alert-error\">");
                                                                            out.println("Form error: " + addClientErr);
                                                                            out.println("</p>");
                                                                            session.setAttribute(SessionConstants.ADMIN_ADD_COUNTRY_FLOAT_ERROR_KEY, null);
                                                                        }

                                                                        if (StringUtils.isNotEmpty(addClientSuccess)) {
                                                                            out.println("<p class=\"alert alert-success\">");
                                                                            out.println("You have successfully added float to the country. You may add others below. "
                                                                                    + "Please relogin to system to get new listing of country floats.");
                                                                            out.println("</p>");
                                                                            session.setAttribute(SessionConstants.ADMIN_ADD_COUNTRY_FLOAT_SUCCESS_KEY, null);
                                                                        }
                                                                    %>
                                                                    <fieldset>
                                                                    <div class="form-group">
                                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12">Account
                                                                        </label>
                                                                        <div class="col-md-7 col-sm-7 col-xs-12">
                                                                           <select name="accountUuid" id="input" class="form-control col-md-3 col-xs-12">
                                                                                <option value="">select Account from dropdown</option>
                                                                                    <%
                                                                                for (Account a : accountList) {
                                                                                    out.println("<option value=\"" + a.getUuid() + "\">"
                                                                                    + a.getFirstName() + " " + a.getLastName() + " " + a.getAccounttype() + "</option>");

                                                                                    }//end for (Account a : accountList)
                                                                                %>
                                                                                </select>
                                                                        </div>
                                                                     </div>
                                                                    <div class="form-group">
                                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12">Country
                                                                        </label>
                                                                        <div class="col-md-7 col-sm-7 col-xs-12">
                                                                           <select name="countryUuid" id="input" class="form-control col-md-3 col-xs-12">
                                                                                <option value="">select country from dropdown</option>
                                                                                   <%
                                                                            Iterator i = countryHash.keySet().iterator();

                                                                            while (i.hasNext()) {

                                                                                String uuid = (String) i.next();

                                                                                String name = (String) countryHash.get(uuid);
                                                                        %>

                                                                        <option value="<%=uuid%>" ><%=name%></option>

                                                                        <%
                                                                            }
                                                                        %>
                                                                                </select>
                                                                        </div>
                                                                     </div>




                                                                    <div class="form-group">
                                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12">Amount in Local currency
                                                                        </label>
                                                                        <div class="col-md-7 col-sm-7 col-xs-12">
                                                                          <input id="input" name="amount" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                                                               out.println("value=\"" + StringUtils.trimToEmpty(ParamHash.get("amount")) + "\"");
                                                                                 %> >
                                                                        </div>
                                                                     </div>
<input type="hidden"  name="username"  					<%
                                           out.println("value=\"" + StringUtils.trimToEmpty(sessionKey) + "\"");
                                    %>>

                                                                        <div class="control-group ">

                                                                            <td><label class="control-label">Date&nbsp;</label></td>
                                                                            <div class="controls">
                                                                                <td><select name="addDay" id="input" class="span2">
                                                                                    <%
                                                                                        for (int j = 1; j < DAYS_IN_MONTH; j++) {
                                                                                            if (j == DAY_OF_MONTH) {
                                                                                                out.println("<option selected=\"selected\" value=\"" + j + "\">" + j + "</option>");
                                                                                            } else {
                                                                                                out.println("<option value=\"" + j + "\">" + j + "</option>");
                                                                                            }
                                                                                        }
                                                                                    %>
                                                                                 </select>-</td>
                                                                                <td> <select name="addMonth" id="input" class="span2">
                                                                                    <%
                                                                                        for (int j = 1; j < 13; j++) {
                                                                                            if (j == MONTH) {
                                                                                                out.println("<option selected=\"selected\" value=\"" + j + "\">" + j + "</option>");
                                                                                            } else {
                                                                                                out.println("<option value=\"" + j + "\">" + j + "</option>");
                                                                                            }
                                                                                        }
                                                                                     %>
                                                                                </select>-</td>
                                                                                <td> <select name="addYear" id="input" class="span2">
                                                                                    <%
                                                                                        for (int j = YEAR; j < YEAR_COUNT; j++) {
                                                                                            if (j == YEAR) {
                                                                                                out.println("<option selected=\"selected\" value=\"" + j + "\">" + j + "</option>");
                                                                                            } else {
                                                                                                out.println("<option value=\"" + j + "\">" + j + "</option>");
                                                                                            }
                                                                                        }
                                                                                    %>
                                                                                </select></td>
                                                                            </div>
                                                                        </div>
                                                                    </fieldset>
                                                                    <footer id="submit-actions" class="form-actions">
                                                                        <button id="submit-button" type="submit" class="btn btn-primary" name="action" value="CONFIRM">Add</button>
                                                                    </footer>
                                                                <!--</div>-->
                                                            <!--</div>-->
                                                        <!--</div>-->
                                                    </form>

                                                     </div>
                                                    </div>
                                                </div>
                                            </div><!-- ./col -->

                                    </div>

                                </div>
                            </div>
                        </div>
                                                                <div class="clearfix"></div>
                                            <div class="row">
                        <div class="col-md-12">
                            <div class="x_panel">
                                <div class="x_content">

                                    <div class="row">

                                            <div class="col-lg-6 col-xs-6">
                                                <form name="pageForm" method="post" action="addFloat.jsp">
					                    <%                                            if (!mainfloatPage.isFirstPage()) {
					                    %>
					                    <input class="btn btn-info" type="submit" name="page" value="First" />
					                    <input class="btn btn-info" type="submit" name="page" value="Previous"/>

					                    <%
					                        }
					                    %>
					                    <span class="pageInfo">Page
					                        <span class="pagePosition currentPage"><%= mainfloatPage.getPageNum()%></span> of
					                        <span class="pagePosition"><%= mainfloatPage.getTotalPage()%></span>
					                    </span>
					                    <%
					                        if (!mainfloatPage.isLastPage()) {
					                    %>
					                    <input class="btn btn-info" type="submit" name="page"value="Next">
					                    <input class="btn btn-info" type="submit"name="page" value="Last">
					                    <%
					                        }
					                    %>
					                </form>
                                                <!-- small box -->
                                                <div class="small-box">
                                                    <div class="inner">
                                                     <i class="icon-eye-open icon-large"></i>
                                                        <div class="alert alert-block alert-success">
                                                                    <p>
                                                                      CURRENT MAIN FLOAT
                                                                    </p>
                                                                    </div>

                                                    <div class="x_content">
                                                        <table id="example" class="table table-striped responsive-utilities jambo_table">
                                                        <!--<table class="table table-striped bootstrap-datatable datatable">-->
                                                            <thead>
                                                                <tr class="headings">
                                                                <th></th>
                                                                <th>Account</th>
                                                                <th>Balance</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                 <%
                                                            if (mainfloatList != null) {
                                                                for (MasterAccountFloatPurchase code : mainfloatList) {
                                                                %>

                                                                <tr>
                                                                    <td width="5%"><%=mainfloatCount%></td>
                                                                    <td class="center"><%=accountHash.get(code.getAccountUuid())%></td>
                                                                    <td class="center"><%=code.getBalance()%></td>
                                                                </tr>
                                                                 <%
                                                                    mainfloatCount++;
                                                                }
                                                                }

                                                            %>


                                                            </tbody>
                                                        </table>
                                                     </div>



                                                    </div>
                                                </div>
                                            </div><!-- ./col -->

                                            <div class="col-lg-6 col-xs-6">
                                                            <form name="pageForm" method="post" action="addFloat.jsp">
					                    <%                                            if (!mainfloatpercountryPage.isFirstPage()) {
					                    %>
					                    <input class="btn btn-info" type="submit" name="page" value="First" />
					                    <input class="btn btn-info" type="submit" name="page" value="Previous"/>

					                    <%
					                        }
					                    %>
					                    <span class="pageInfo">Page
					                        <span class="pagePosition currentPage"><%= mainfloatpercountryPage.getPageNum()%></span> of
					                        <span class="pagePosition"><%= mainfloatpercountryPage.getTotalPage()%></span>
					                    </span>
					                    <%
					                        if (!mainfloatpercountryPage.isLastPage()) {
					                    %>
					                    <input class="btn btn-info" type="submit" name="page"value="Next">
					                    <input class="btn btn-info" type="submit"name="page" value="Last">
					                    <%
					                        }
					                    %>
					                </form>
                                                <!-- small box -->
                                                <div class="small-box">
                                                    <div class="inner">
                                                        <div class="alert alert-block alert-success">
                                                                    <p>
                                                                      FLOAT DISTRIBUTION BY COUNTRY
                                                                    </p>
                                                                    </div>

                                                    <div class="x_content">
                                                        <table id="example" class="table table-striped responsive-utilities jambo_table">
                                                        <!--<table class="table table-striped bootstrap-datatable datatable">-->
                                                            <thead>
                                                                <tr class="headings">
                                                                <th></th>
                                                                <th>Country</th>
                                                                <th>Account</th>
                                                                <th>Balance</th>
                                                                <th>Currency</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                 <%
                                                            if (mainfloatpercountryList != null) {
                                                                for (AccountPurchaseByCountry codes : mainfloatpercountryList) {
                                                                %>

                                                                <tr>
                                                                    <td width="5%"><%=mainfloatpercountryCount%></td>
                                                                    <td class="center"><%=countryHash.get(codes.getCountryUuid())%></td>
                                                                    <td class="center"><%=accountHash.get(codes.getAccountUuid())%></td>
                                                                    <td class="center"><%=codes.getBalance()%></td>
								    <td class="center"><%=countrycurrencyHash.get(codes.getCountryUuid())%></td>
                                                                </tr>
                                                                 <%
                                                                    mainfloatpercountryCount++;
                                                                }
                                                                }

                                                            %>


                                                            </tbody>
                                                        </table>
                                                     </div>
                                                    </div>
                                                </div>
                                            </div><!-- ./col -->

                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>



                    </div>





















                <!-- footer content -->
                <footer>
                    <div class="">
                        <p>Copyright@ImpalaPay 2014-2015</p>
                            <a href="#">Terms &amp; Conditions</a> | <a href="#">Privacy
                            Policy</a> | ImpalaPay Ltd <%= Calendar.getInstance().get(Calendar.YEAR)%>. All rights reserved.
                            <!--<img id="madeInKenya" alt="Made in Kenya" src="#" width="100" height="100" />-->
                        </p>
                    </div>
                    <div class="clearfix"></div>
                </footer>

                <!-- /footer content -->
            </div>
            <!-- /page content -->
        </div>

    </div>

    <script src="../js/bootstrap.min.js"></script>

    <!-- chart js -->
    <script src="../js/chartjs/chart.min.js"></script>
    <!-- bootstrap progress js -->
    <script src="../js/progressbar/bootstrap-progressbar.min.js"></script>
    <script src="../js/nicescroll/jquery.nicescroll.min.js"></script>
    <!-- icheck -->
    <script src="../js/icheck/icheck.min.js"></script>

    <script src="../js/custom.js"></script>

</body>

</html>

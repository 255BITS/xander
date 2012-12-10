# Xander 

Multivariate Testing in JavaScript made easy.  Also see [xander.io](http://xander.io), the pro version of xander.

## Principles:

* Multivariate testing should be simple for developers and designers
* Variants should be cheap to add and simple to view
* Analytics should be useful and available for review
* If you are using [xander.io](http://xander.io), your website should get better over time without manual intervention.

## Library Requirements

* [xander.io](http://xander.io) (optional)
* Google Analytics 
* jQuery

## Installation

* Include xander-client javascript file

### CDN 

```html
  <script src='http://cdn.xander.io/xander-1.0.js'></script>
```

## Usage

### Multivariate testing for HTML elements 

* Defining a variant
    ```html
      <div id="callToAction">
        <div data-variant="logic" class='red hide'>
          If you have a website with users, you should be multivariate testing.  It's the only way to ensure your changes are actually what users want.
        </div>
        <div data-variant="google" class='blue hide'>
          Multivariate testing is used by Google to optimize their search results.
        </div>
        <div data-variant='silly' class='green hide'>
          You can't multivariate test your life... yet - but now you can easily multivariate test your websites!
        </div>
      </div>
    ```

* This variant sets up a three way test between logic, google, and silly calls to action variants so we can see which phrasing works best. 
* The data will be available in Google Analytics (or [xander.io](http://xander.io) if you chose to use it)
* We have a simple hide class that sets 'display: none'.  This avoids flicker after the page loads.

### Multivariate testing for CSS classes

* Defining testable CSS classes
    ```html 
      <section id='signup' data-css-variants="green blue" />
    ```

* One of the two green or blue classes will be added to your #signup button.
* Variation reports are based on ids 

## Goals

Goals are a simple way to track conversions.  In Google Analytics they correlate specifically to _trackPageview's.

### Defining a goal

```html
  <form data-goal="New User" onsubmit='processInfo(); return false'>
    <!-- Here's where you could multivariate test the form. -->
    <h1> Sign up for our amazing product </h1>
    <input type='submit'> Sign up </input>
  </form>
```

Goals in Xander work by binding to an element's jquery click event (or submit event in the case of a form).  

If you can't get the goal to trigger - console.log is your friend.  Open up your console and you will see some messages from xander when your page is setup and again when a goal is pressed.

If all else fails, you can call:

```javascript
  xander.goalReached("New User");
```


### Verifying your variant test is setup
<!--
#### Step 1 - Verify Goals

* use ?showVariants=true in your test URL.
* the current variant selected and goals completed this session are shown at the top of the page.
* click your goal
* watch your goal count increase

---

#### Step 2 - verify with Google Analytics
-->
* Setup your variants and page goal
* Click your page goal
* Log in to Google Analytics
* If you are using Google Analytics and not [xander.io](xander.io), you will likely face a problem where Google Analytics will reflect your test data.  This can be filtered in google analytics, or just use [http://xander.io](xander.io).

## Rerolling a page

You can now call a rerollVariants method to get a whole new version of your site.

```js
  xander.reroll(); // reroll all CSS and content variants
  xander.reroll($("#choices")); // reroll the #choices variant
```

# Commercial offerings

If you like xander, but don't like the sample distribution using Math.rand() - or don't like having to review your variant's performance, check out [xander.io](http://xander.io) .  It's a SAAS that uses 90/10 testing to figure out your best performing variant (with a friendly UI).

Note, xander inserts a tracking pixel on your site in the event that you would
like to upgrade.  To disable this, add this after your script include.
```html
  <script>
    xander.disableTrackingPixel()
  </script>
```

# Related Work

* [ABalytics](https://github.com/danmaz74/ABalytics)
* Send us a message if there's anything else that should be listed.

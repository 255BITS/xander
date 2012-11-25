# Xander 

Multivariate Testing made easy.

## Principles:

* Multivariate testing should be simple
* Results should be available in Analytics
* It should be easy to see all the variants

## Library Requirements

* Google Analytics
* jQuery

## Installation

* Include xander-client javascript file

## Usage

### Multivariate testing for HTML elements 

* Options wrapped in tags
    ```html
      <section id="buttons">
        <button data-variant='green' class='green'>
        </button>
        <button data-variant="red" class='red'>
        </button>
        <button data-variant="blue" class='blue'>
        </button>
      </section>
    ```

* Initially hide all elements that are data-variants.
* Specify ?showVariants=true to your URL for a suprise!
* Variation reports are based on root element id 

### Multivariate testing for CSS classes

* Add variant classes
    ```html 
      <section id='test3' data-css-variants="class1 class2" />
    ```

* One of the data-css-variants will be added as a class to your section.
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

### Potential gotchas

Goals are a relatively new addition to Xander, so we haven't quite tested out the following use cases across the many different browsers in common use:

* a tags that redirect the page (simple a hrefs without target=_blank)
* forms that do a full page submit (ajax forms seem ok)

That said if you are creating things as a single page application, you shouldn't have any issues using Xander's goals.

## Rerolling a page

You can add ?showVariants=true to your url to see all your variants.  You can now call a rerollVariants method to get a whole new version of your site.

```js
  xander.reroll(); // reroll all CSS and content variants
  xander.reroll($("#choices")); // reroll the #choices variant
```

## Future
* Free with Math.random().  90/10, ensured distribution, and Best Site Finder option in planning stages as services.

# Related Work

* [ABalytics](https://github.com/danmaz74/ABalytics)

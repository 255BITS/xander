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

## Future
* Free with Math.random().  90/10, ensured distribution, and Best Site Finder option in planning stages as services.

# Related Work

* [ABalytics](https://github.com/danmaz74/ABalytics)

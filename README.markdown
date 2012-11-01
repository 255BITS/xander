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

* Options wrapped in tags
    ```html
      <section data-variants="buttons">
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

## Future
* Free with Math.random().  90/10, ensured distribution, and Best Site Finder option in planning stages as services.

# Related Work

* [ABalytics](https://github.com/danmaz74/ABalytics)

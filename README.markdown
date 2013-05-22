# Alive

Alive is a toy application that turns still images into interactive playthings.

## Overview

Alive is an image toy that scans an image using the webcam and breaks it down into
objects that animate when you touch them with the mouse.
It runs in a web browser.
**Compatibility is guaranteed with up-to-date Google Chrome only.**

## Installation

### Run online

Alive is hosted at <http://www.ug.it.usyd.edu.au/~dbuc6168/alive>.
Follow the link to try Alive with no installation required.

### Run locally

If you want to run Alive locally, first get the code either distributed with this
manual, or by cloning from GitHub:

    git clone git@github.com:eightyeight/alive.git
    cd alive
    git submodule init
    git submodule update

To run Alive, you'll need to provide a local server.
This can be done by installing WAMP, warp, nginx or any other web server that
can serve static content - or by using the simple Python server that is included
with Alive.
Using Python 2.7, run the script:

    python Alive.py

and visit <http://127.0.0.1:3000> in your browser.
You may close the server console window once you are finished using Alive.

## Use

Alive's interface is very simple.
When you visit the webpage, you will see a canvas containing the first test image,
below which are several options.
You can select the other test image or the webcam as a source.
Click on an area of background colour in the image, and the app will start to
find objects.
The image will darken while this is happening.

When the image lightens again, simply move your mouse around the page to make the
objects animate.
Click the image again to return to the starting state.


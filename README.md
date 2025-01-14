# ISC Open Science Workflow Training
This repository holds code and presentations for the 2025 ISC Billfish Working Group Meeting. 

## Rendering and publishing

Rendering and publishing of the repo [webpage](https://moshima-pifsc.github.io/ISC_OSworkflow_training/) is done automatically via GitHub Actions. In order to render a local version of the webpage, clone the repo to your local machine, ensure [Quarto](https://quarto.org/docs/get-started/) is installed and run
```
quarto render
```
from a Terminal window opened in the project directory. The locally rendered webpage will be located in the `_site/` directory and can be accessed by opening `_site/index.html` in the browser of your choice. Note that the [embedio](https://quarto.thecoatlessprofessor.com/embedio/) Quarto extension is used to embed the presentation slides into the webpage and the [codewindow](https://github.com/EmilHvitfeldt/quarto-revealjs-codewindow) Quarto extension is used to add styled codeblocks into the presentation slides. These extensions are distributed with the repository however if the webpage does not render properly these extensions may need to be installed.

## Github Disclaimer

This repository is a scientific product and is not official communication of the National Oceanic and Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project code is provided on an ‘as is’ basis and the user assumes responsibility for its use. Any claims against the Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.

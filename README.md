# Grid-EYE-Research-Project
This repository contains the code for a proof-of-concept installation based on the Grid-EYE sensor and panStamp microcontrollers. It includes the handler script, the operating code for the panStamps and some basic training data for the GRT. We used the setup to track subjects performing sport exercises in front of the installation.

# Hardware

 - Panasonic Grid-EYE
 - 3x panStamp
 - 5x Neopixel
 - Batteries, wiring, breadboards etc.

# Setup and Installation

 1. Install the GRT  (http://www.nickgillian.com/wiki/pmwiki.php/GRT/Download)
 2. Upload the Sketches to the panStamps
 3. Start the handler Sketch (Check if the right USB port is selected)
 4. Start the GRT
   * Select Classification mode (Timeseries Mode, Classification Mode)
   * Set number of inputs to 64
   * Load training data via the Data manager
   * Train the GRT
 5. When the pipeline works activate highpass and background filter by pressing the keys "H" and "B"


# Contributors
Andreas Berst (andreas.berst@uni-weimar.de)<br>
Kevin Schminnes (kevin.schminnes@uni-weimar.de)

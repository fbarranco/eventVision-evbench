# Dataset for Visual Navigation with Neuromorphic Methods
This directory contains Matlab (R) implementations of methods to generate and handle DVS data for building a dataset

Standardized benchmarks for Computer Vision provide a very powerful tool for the development of new improved techniques in the field. Frame-free event-driven vision still lacks of datasets to assess the accuracy of their methods. Furthermore, the visibility of Event-driven Vision will be enhanced thanks to the comparison to frame-based conventional Computer Vision to make researchers in the field understand the potential of this novel technology.

Benchmarks for Event-driven Vision and Computer Vision are significantly different. Frame-free sensors collect events that are triggered due to changes in the image while conventional sensors collect the luminance of the scene. If we want to compare methods for heterogeneous sensors, we require a conventional sensor and a frame-free sensor collecting events from the same scene, so that the processing for frame-based and event-driven techniques can be applied to the same data. In our case, we record the sequences with the DAVIS sensor [1] that collects asynchronous events and synchronous frames. 

## Davis sensor calibration ##

The DAVIS240b sensor is mounted on a stereo rig with a Microsoft Kinect Sensor that provides the RGB image and the depth map of the scene. The stereo rig is mounted on a Pan Tilt Unit (PTU-46-17P70T by FLIR Motion Control Systems). Finally, the Pan Tilt Unit is on-board a Pioneer 3DX Mobile Robot. The PTU controls the pan and tilt angles and angular velocities, while the Pioneer 3DX Mobile Robot is in control of the direction of translation and the speed. There are ROS (Robot Operating System) packages available for the PTU and the Pioneer 3DX mobile robot. Our dataset provides the following:

  - The 3D motion parameters: 3D translation of the camera and 3D pose}. They are provided by the PTU and the Pioneer Mobile Robot. Assuming that their coordinate centers are the same, they have to be calibrated with respect to the DAVIS coordinates.
  - The image depth. It is obtained by the Microsoft Kinect Sensor (RGB-D sensor). A stereo calibration to register the Kinect depth to the DAVIS camera coordinates is required.
  - The 2D motion flow field ground-truth. Using the 3D motion parameters and the depth from the DAVIS coordinate system, the 2D motion flow field ground-truth of the scene is reconstructed.

The tasks implemented in this repository are:

  - Calibration of DAVIS and RGB-D sensor
  - Calibration of DAVIS and PTU
  - Generating 2D motion flow field

## More documentation ##

If you use any of the methods or code, please cite the article
F. Barranco, C. Fermuller, Y. Aloimonos, T. Delbruck
A dataset for Visual Navigation with Neuromorphic Methods
Frontiers in Neuroscience: Neuromorphic Engineering, 2015.

    @article{barranco_dataset_2015,
      title={A dataset for Visual Navigation with Neuromorphic Methods},
      author={Barranco, Francisco and Fermuller, Cornelia and Aloimonos, Yiannis and Delbruck, Tobi},
      journal={Frontiers in Neuroscience: Neuromorphic Engineering},
      pages={1--16},
      year={2015}
    }

Some additional information is available at:
https://www.ugr.es/~cvrlab/projects/realtimeasoc/dataset/evbench.html

## Example ##

Please, take a look at reconstructFlow.m for an example that shows in a general way the main functionalities of the repository.
The code uses some data and matfiles that are already available in the repository (./DATA). Anyway, more sequences and ground-truth can be found in the project site. The example file reconstructFlow also includes some comments to understand how the matfiles with the depth and the DAVIS, RGB-D sensor, and PTU calibration parameters have been computed. Note that, all the parameters should be re-computed with a new configuration.

## Update: October 2016 ##
Please, note that some of the code and the benchmark have been updated.
The values of the flow are computed as m/frame. This means that, since event sequences (.aedat) are recorded at different frame rates, also the time scale changes for each sequence. Take a look at the variable "frame_rate" (microsecond) in the code to translate into m/microsecond if necessary.

Please report problems, bugs, or suggestions to
fbarranco_at_ugr_dot_es (Replace _at_ by @ and _dot_ by .).

Copyright (C) 2015 Francisco Barranco, 11/18/2015, University of Granada.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

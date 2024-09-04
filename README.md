# PerspectiveTaking: A Multimodal Spatial Cognition Assessment Benchmark

## Overview

This repository accompanies a NeurIPS workshop paper submission, providing a benchmark for multimodal spatial cognition assessment with a focus on **perspective taking**. This benchmark explores how AI models approach tasks involving the mental rotation and transformation of objects, tested through tasks commonly used in human cognitive science.

### Why Perspective Taking Matters

Understanding spatial cognition is fundamental for the development of AI systems that interact meaningfully with the world. Perspective taking is a core cognitive process that allows humans to interpret spatial relationships between objects from different viewpoints. This ability develops over time in human cognition and has been studied extensively in cognitive science.

The methods we use to assess AI systems must accurately reflect the cognitive processes we are interested in. By leveraging cognitive science benchmarks, we can compare AI and human cognitive abilities on a developmental timeline, fostering a better understanding of both systems. This ensures that we are measuring not just performance, but whether AI systems are truly learning the cognitive skills humans rely on.

## Benchmark Tasks
This benchmark contains 3 different task types: 1) level 1 (in front/behind evaluation), 2) level 2 spatial (left/right evaluation), and 3) level 2 visual (9/6 or M/W). For each task, there are 16 images each representing an avatar and objects around this avatar at varying degrees. The goal of each task is to evaluate the position of the objects (spatial) or what is displayed on them (visual) from the perspective of the avatar.

<div align="center">
  <img src="/images/jpeg/infront_behind/cube_front_135.jpeg" alt="Cube in front at 135°" style="width:45%; float: left; margin-right: 2%;" />
  <img src="/images/jpeg/left_right/right_cube_270.jpeg" alt="Cube to the right 270°" style="width:45%; float: left;" />
  <br>
  <i>Level 1 stimulus (left) and Level 2 spatial stimulus (right)</i>
  <br>
  <br>
  <img src="/images/jpeg/9_6/6_225.jpeg" alt="6 on cube 225°" style="width:45%; float: left; margin-right: 2%;"/>
  <img src="/images/jpeg/M_W/W_45.jpeg" alt="W on cube 45°" style="width:45%; float: left;" />
  <br>
  <i>Level 2 visual stimulus using numbers (left) and Level 2 visual stimulus using letters (right)</i>
  <br>
</div>

## Repository Structure

The repository is organized into the following directories:

PerspectiveTaking/

├── GPT/                    # Contains code to run GPT task and results

│   └── results/            # GPT task data (e.g., experimental results)

│   └── gpt_task.py         # API code to run the task

│   └── plot_data.py        # Analysis for GPT task

├── Human/                  # Contains code to run human task and results

│   └── data/               # Human task data (e.g., experimental results)

│   └── experiments_code/   # Psychtoolbox experiments code

│   └── averageResults.m    # Analysis for human task

├── images/                 # Benchmark images

│   └── bitmap              # bitmap version for PTB experiments

│   └── jpeg                # jpeg versions for API experiments

├── README.md               # Project overview (this file)

├── requirements.txt        # Dependencies for running the project

└── LICENSE                 # License information


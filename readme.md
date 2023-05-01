# My city driving simulator

Name: Alex Nuzum

Student Number: C19307776

Class Group: TU856

# Description

For this project I wanted to create a a simulation of city life. I wanted to have cars that travel around on the streets and people that walk around on the sidewalk. In this simulation, cars and people travel round the city, stopping when they are about run into each other.

The music was made by me. The right hand swings between 7/4 time and 5/4 time, and the left hand is in 6/4 time. I think I did a good job at creating a ambient lullaby befiting of a city simulation.

## Video

[![YouTube](readme-files/screenshot-1.png)](https://youtu.be/f9tmgOyUgD8)

## How it works

I found a road generation algorithm [here](https://kidscancode.org/blog/2018/09/godot3_procgen2/) which I adapted to work in 3d. It was originally programmed to work with 2D tiles. I created all the road textures myself. I also created all the building and vehicle models myself in blender. Almost all non-road squares with buildings.

I created a path generation algorithm. Cars and people then seek the nearest target in a list of targets. I check if the road at an xz position is of a certain type and determine where the car or person will move next. I do this 10000 times in a loop for every car as they are placed in the scene. This generates a path that each car will travel throughout the simulation.

The path generation algorithm also determines which side of the road cars will be on based on which direction they are moving. Cars drive on the left side of the road much like our own road laws.

The people use the same algorithm with the only difference being that people are offset from the center of the road by 0.9 units as the places them on the footpath.

Both people and cars stop/slow down when they are about to run into other people or cars. I originally wanted to have cars properly stop and wait for others to take turns / cross in front etc. but I couldn't figure out how to get this to fully work.

Lastly, I added a first person driving mode. When the player presses V, the camera will toggle between following a random car allowing the player to move the camera themselves.

## Screenshots
![Zoomed in city screenshot](readme-files/screenshot-2.png)
![Nightlife on Skaro](readme-files/screenshot-3.png)
![First person driving mode](readme-files/screenshot-4.png)

---

# List of classes/assets

| Class/asset | Source |
|-----------|-----------|
| BoidMovement.gd | Self written |
| CameraMovement.gd | Self written |
| FPS.gd | Self written |
| GenerateMap.gd | 1/2 Self written and 1/2 Modified from [reference](https://kidscancode.org/blog/2018/09/godot3_procgen2/) |
| Globals.gd | Self written |
| PersonMovement.gd | Self written |
| Other files | Unused / experiments |

# Analysis
Though the algorithms behind boids' movments are quite simple, the emerging behaviour gives the illusion that the cars and people are navigating the city on their own. I also like how cars slow down for each other though I wished that I could have figured out how to detect collisions between areas and meshes.

This would have allowed me to detect when an area which extended out in front of a vehicle collided with the vehicle in front, not the area itself. This would have allowed me to check for collisions from the front and not the back. This could have been don with raycasts but I couldn't figure out why my raycasts were nto working right and couldn't figure out how to visualise them either.
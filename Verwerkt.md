# Verwerkt uit het boek

## Meeting notes 21/02

* *Look at FOSSEN’s Github (MSS + Marine craft Hydrodynamics and motion control)*
* Read the lecture slides on modelling. Understand hydrostatics and hydrodynamics
* *Check the MSS toolbox. Play around with the built-in functions (have fun ;) ) look at how they work*
* Check the different already existing AUV that are modelled. Find one that you like (and that is relatively simple), study it, understand it, play with it.

* If possible, try to modify the existing model **(create a copy)** and check the influence of those changes (see if it makes sense).
⇒ With the knowledge gained, see **what are the possible modules** constituting an AUV. possibility to decouple some factors ? Ask yourself questions, try to find answers.
**Maybe try to start playing with modularity here
* When you feel comfortable: try to recreate the model of the chosen AUV in a **simpler fashion**.
⇒ Idea is to work on a simple AUV that you understand.
* Verify the created model by comparing it to the chosen AUV. 
⇒ Modify created/modified model if needed
* If the created/modified model is verified, work on this one for the rest of the project as it will be easier. Instore the modular design and try to see if the **consequences of the changes are realistic.**

**FROM HERE, I would say that the biggest part of the project is done**

* Include the modular design to the more complex AUV, see if it still works. Modify/tweak the modularity if needed.
* If still after all that you have time, then try to imagine your own AUV. Play with the model, test the limits to see if there are any singularities that may arise (ex. theta=+-90° when using euler angles, etc.) 


### Questions

1. What exactly is meant with decouple some factors ? 
2. What is meant with in a simpler fashion ?
3. More complex AUV, is another AUV in another model
4. More generally deadlines hand in and presentation ? 
5. What should be included in the report ? (Literatuurstudie, state of the art ?)
6. Could there be a way to get chapter 8 of the 2021 book ? 


## Plan


0. Check MSS Toolbox
1. Better understanding of AUV modelling (Bekijk boek tot code volledig begrepen)
2. Check if other AUV 
3. Remake AUV 
4. Voeg wat modulariteit toe (identificeer mogelijke modules) 
5. Decouple factors **??** 
6. Simpler fashion **??** 
7. Verify 
8.  More modular design **??**

### Te doen voor 1

*  **Slides H8** 
   *  Foundation:
       * 2 Kinematics/ 6DOF EOM
       * 3 Rigid-Body kinetics
       * 4 Hydrostacs
       * 6 Maneuvering theory
       * END GOAL 7.5.6
     * Goals
       * Write down the **6-DOF equations of motion** of an underwater vehicle using Euler angles and unit quaternions.
       * Be able to apply **symmetry conditions** to 6-DOF models and identify which elements in the M, C and D matrices are zero.
       * Write down the **gravity and buoyance vector g** for different types of underwater vehicles.
       * Understand what we mean with a **neutrally buoyant vehicle** and how the location of the **CG** and the **CB** affects the restoring forces of a submerged vehicle.
       * Understand how different **models for underwater vehicles** are built up and be able to distinguish between:
         * Longitudinal and lateral models for submarines
         * Decoupled models for “flying underwater vehicles”
         * Cylinder-shaped vehicles and Myring-type hulls
         * Spherical-shaped vehicles


* Remus
    * begrijpen
    * Hermaken
* Modulair SIMULINK model

### Progress

0. Done
1. Done
   1. minder aandacht aan de latere delen
2. NPSAUV
   1. Ziet er interessant uit, maar code ingewikkelder
   2. Beginnen bij de Remus
3. Begin bij het gewoon kopiëren van de remus 




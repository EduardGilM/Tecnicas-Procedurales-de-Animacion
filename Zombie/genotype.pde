class Genotype {
    float seekMultiplier;
    float fleeMultiplier;
    float arriveMultiplier;
    float wanderMultiplier;
    float pursueMultiplier;
    float evadeMultiplier;
    float pathFollowMultiplier;
    float obstacleAvoidanceMultiplier;
    float separationMultiplier;
    float alignmentMultiplier;
    float cohesionMultiplier;
    float speedMultiplier;  // Multiplicador de velocidad máxima
    float forceMultiplier;  // Multiplicador de fuerza máxima

    Genotype() {
        this.seekMultiplier = random(0.5, 6);
        this.fleeMultiplier = random(0.5, 6);
        this.arriveMultiplier = random(0.5, 6);
        this.wanderMultiplier = random(0.5, 6);
        this.pursueMultiplier = random(0.5, 6);
        this.evadeMultiplier = random(0.5, 6);
        this.pathFollowMultiplier = random(0.5, 6);
        this.obstacleAvoidanceMultiplier = random(0.5, 6);
        this.separationMultiplier = random(0.5, 6);
        this.alignmentMultiplier = random(0.5, 6);
        this.cohesionMultiplier = random(0.5, 6);
        this.speedMultiplier = random(0.7, 1.5);  // Varía la velocidad entre 70% y 150%
        this.forceMultiplier = random(0.7, 1.5);  // Varía la fuerza entre 70% y 150%
    }
    
    Genotype copy() {
        Genotype newGenotype = new Genotype();
        newGenotype.seekMultiplier = this.seekMultiplier;
        newGenotype.fleeMultiplier = this.fleeMultiplier;
        newGenotype.arriveMultiplier = this.arriveMultiplier;
        newGenotype.wanderMultiplier = this.wanderMultiplier;
        newGenotype.pursueMultiplier = this.pursueMultiplier;
        newGenotype.evadeMultiplier = this.evadeMultiplier;
        newGenotype.pathFollowMultiplier = this.pathFollowMultiplier;
        newGenotype.obstacleAvoidanceMultiplier = this.obstacleAvoidanceMultiplier;
        newGenotype.separationMultiplier = this.separationMultiplier;
        newGenotype.alignmentMultiplier = this.alignmentMultiplier;
        newGenotype.cohesionMultiplier = this.cohesionMultiplier;
        newGenotype.speedMultiplier = this.speedMultiplier;
        newGenotype.forceMultiplier = this.forceMultiplier;
        return newGenotype;
    }
}
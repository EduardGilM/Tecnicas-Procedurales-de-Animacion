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
    float speedMultiplier;
    float forceMultiplier;

    Genotype() {
        this.seekMultiplier = random(0.5, 6);
        this.fleeMultiplier = random(0.5, 6);
        this.arriveMultiplier = random(0.5, 6);
        this.wanderMultiplier = random(0.5, 3);
        this.pursueMultiplier = random(0.5, 6);
        this.evadeMultiplier = random(0.5, 6);
        this.pathFollowMultiplier = random(0.5, 6);
        this.obstacleAvoidanceMultiplier = random(0.5, 6);
        this.separationMultiplier = random(3, 4);
        this.alignmentMultiplier = random(1.5, 6);
        this.cohesionMultiplier = random(0.5, 3);
        this.speedMultiplier = random(0.7, 0.8);
        this.forceMultiplier = random(0.7, 0.8);
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

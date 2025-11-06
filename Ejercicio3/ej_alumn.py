import gym
import numpy as np
import random
import matplotlib.pyplot as plt

from env_2D import *
import gymnasium as gym
from gymnasium.envs.toy_text.frozen_lake import generate_random_map
from agentesRL import *

# Ejemplo de uso
if __name__ == "__main__":
    plt.figure(figsize=(10, 5))  # Crear la figura antes del entrenamiento

    # ==================== CONFIGURACIÓN DEL ENTORNO ====================
    use_frozen_lake = True  # True: FrozenLake | False: Environment2D
    
    multigoal = False
    multinit = False
    
    # Configuración para Environment2D
    obstacle_percentage = 0.0
    
    # Configuración para FrozenLake
    is_slippery = True  # Desactivar el resbalado para hacer el ambiente determinista 
    
    # ==================== CONFIGURACIÓN DEL AGENTE ====================
    use_goal_position = False 
    use_distance_reward = False 
    
    # Fórmula: epsilon = k - (k-b) * (episodio_actual / num_episodes)
    epsilon_decay = True
    epsilon_k = 0.99  # k: valor MÁXIMO de epsilon (aumentado para más exploración)
    epsilon_b = 0.01  # b: valor MÍNIMO de epsilon
    
    num_test_runs = 5  # Número de pruebas a ejecutar después del entrenamiento
    
    if use_frozen_lake:
        frozen_size = 4
        env = gym.make('FrozenLake-v1', desc=generate_random_map(size=frozen_size), is_slippery=is_slippery)
        print(f"=== Usando FrozenLake ===")
        print(f"Tamaño: {frozen_size}x{frozen_size}, Slippery: {is_slippery}")
        print("Mapa:")
    else:
        print("=== Usando Environment2D ===")
        env = Environment2D(15, 15, obstacle_percentage, multigoal, multinit)
        print(f"Tamaño: 15x15, Obstáculos: {obstacle_percentage*100}%")
        print(f"Multigoal: {multigoal}, Multinit: {multinit}")
    
    print()
    
    # Crear el agente con los parámetros de aprendizaje
    agent = Agent(env, alpha=0.95, gamma=0.99, epsilon=0.99, render_training=False, 
                  use_goal_position=use_goal_position, use_distance_reward=use_distance_reward,
                  epsilon_decay=epsilon_decay, epsilon_k=epsilon_k, epsilon_a=0, epsilon_b=epsilon_b, 
                  frozen_env=use_frozen_lake)
    
    # Entrenar el agente con Q-Learning
    print("\nEntrenando el agente con Q-Learning...")
    num_episodes = 10000000  # Reducir episodios para el mapa más pequeño
    rewards = agent.train_q_learning(num_episodes)
    print("Entrenamiento completado!")
    
    # Cerrar la figura de entrenamiento
    plt.close()

    window_size = 1000
    moving_avg = np.convolve(rewards, np.ones(window_size)/window_size, mode='valid')

    plt.figure(figsize=(10, 5))
    plt.plot(rewards, alpha=0.3, label='Recompensas por episodio')
    plt.plot(range(window_size-1, len(rewards)), moving_avg, linewidth=2, label=f'Media (W={window_size})')
    plt.xlabel('Episodio')
    plt.ylabel('Recompensa Total')
    plt.title('Recompensas acumuladas durante el entrenamiento')
    plt.legend()
    plt.grid(True)
    plt.show()
    
    print(f"\nProbando el agente entrenado {num_test_runs} veces...")
    env_test = gym.make('FrozenLake-v1', desc=generate_random_map(size=frozen_size), is_slippery=is_slippery, render_mode='human') if use_frozen_lake else Environment2D(15, 15, obstacle_percentage, multigoal, multinit)
    agent.env = env_test
    agent.test_agent(num_test_runs)
    
    
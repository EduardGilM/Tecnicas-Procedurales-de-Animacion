
import numpy as np
import random
import matplotlib.pyplot as plt

# Clase Agente
class Agent:
    def __init__(self, env, alpha=0.1, gamma=0.9, epsilon=0.01, render_training=False, pause_time=0.1, 
                 use_goal_position=True, use_distance_reward=False, 
                 epsilon_decay=False, epsilon_k=50, epsilon_a=0.01, epsilon_b=5, frozen_env=False):
        self.env = env
        self.alpha = alpha
        self.gamma = gamma
        self.epsilon = epsilon
        self.initial_epsilon = epsilon  # Guardar epsilon inicial
        self.render_training = render_training  # Flag para renderizar el entrenamiento
        self.pause_time = pause_time  # Tiempo de pausa para el renderizado
        self.use_goal_position = use_goal_position  # Flag para incluir posición del objetivo en la tabla Q
        self.use_distance_reward = use_distance_reward  # Flag para dar recompensa basada en distancia
        
        self.epsilon_decay = epsilon_decay
        self.epsilon_k = epsilon_k  # k: valor máximo de epsilon
        self.epsilon_a = epsilon_a  # a: no se usa en decay lineal
        self.epsilon_b = epsilon_b  # b: valor mínimo de epsilon
        self.current_episode = 0  # Contador de episodios para el decay
        self.frozen_env = frozen_env  # Flag para entornos FrozenLake
        
        if self.use_goal_position:
            # Con posición del objetivo: estado = (posición_agente, posición_objetivo)
            # Q[x_agente, y_agente, x_objetivo, y_objetivo, acción]

            self.Q = np.zeros((env.height, env.width, env.height, env.width, 4))
        else:
            # Sin posición del objetivo: estado = solo posición del agente
            # Q[x_agente, y_agente, acción]
            if self.frozen_env:
                # Para FrozenLake, el estado es un entero de 0 a (size*size - 1)
                self.Q = np.zeros((env.observation_space.n, env.action_space.n))
            else:
                self.Q = np.zeros((env.height, env.width, 4))

        if not self.frozen_env:
            self.max_actions_per_episode = env.width*env.height/2
        else:
            self.max_actions_per_episode = env.observation_space.n*env.observation_space.n/2
    
    def _update_epsilon(self, num_episodes):
        """Actualiza epsilon usando decaimiento lineal si está activado.
        La función hace que epsilon decaiga linealmente desde k (máximo) hasta b (mínimo).
        Fórmula: epsilon = k - (k-b) * (episodio_actual / num_episodes)
        donde: k = epsilon máximo (0.9), b = epsilon mínimo (0.05)
        """
        if self.epsilon_decay:
            progress = self.current_episode / num_episodes
            self.epsilon = self.epsilon_k - (self.epsilon_k - self.epsilon_b) * progress
    
    def _calculate_distance(self, state):
        """Calcula la distancia Manhattan desde el estado actual hasta el objetivo."""
        return abs(state[0] - self.env.goal[0]) + abs(state[1] - self.env.goal[1])
    
    def _get_distance_reward(self, state, next_state, base_reward, done):
        """Calcula la recompensa adicional basada en la distancia al objetivo.
        La recompensa está diseñada para que SIEMPRE sea más rentable llegar al objetivo
        que dar vueltas acumulando pequeñas recompensas.
        """
        if not self.use_distance_reward:
            return base_reward
        
        if done and base_reward > 0:
            return base_reward
        
        previous_distance = self._calculate_distance(state)
        current_distance = self._calculate_distance(next_state)
        
        max_possible_distance = (self.env.height - 1) + (self.env.width - 1)
        distance_penalty = -(current_distance / max_possible_distance) * 0.1
        
        distance_change = previous_distance - current_distance
        approach_bonus = distance_change * 0.05
        
        total_reward = base_reward + distance_penalty + approach_bonus

        return total_reward

    def choose_action(self, state):
        if random.uniform(0, 1) < self.epsilon:
            return random.randint(0, 3)  # Exploración
        else:
            if self.frozen_env:
                # Para FrozenLake, el estado es un entero único
                return np.argmax(self.Q[state])
            elif self.use_goal_position:
                goal = self.env.goal
                return np.argmax(self.Q[state[0], state[1], goal[0], goal[1]])
            else:
                return np.argmax(self.Q[state[0], state[1]])  # Explotación

    def train_q_learning(self, num_episodes):
        rewards_per_episode = []  # Lista para almacenar recompensas por episodio
        nactions = 0
        successful_episodes = 0  # Contador de episodios exitosos

        for episode in range(num_episodes):
            if self.frozen_env:
                state, info = self.env.reset()  # FrozenLake devuelve (state, info)
            else:
                state = self.env.reset()  # Environment2D devuelve solo state
            done = False
            total_reward = 0
            if episode%100 == 0: 
                print(f"Training episode: {episode}, actions: {nactions}, epsilon: {self.epsilon:.4f}, alpha: {self.alpha:.4f}, successful: {successful_episodes}")
            nactions = 0    
            
            while not done:
                action = self.choose_action(state)
                if self.frozen_env:
                    next_state, reward, done, truncated, info = self.env.step(action)
                else:
                    next_state, reward, done = self.env.step(action)
                nactions += 1

                # Solo aplicar recompensa basada en distancia para entornos no-FrozenLake
                if self.use_distance_reward and not done and not self.frozen_env:
                    reward = self._get_distance_reward(state, next_state, reward, done)
                
                if self.frozen_env:
                    # Para FrozenLake, el estado es un entero
                    state_idx = state
                    next_state_idx = next_state
                else:
                    goal = self.env.goal
                    if self.use_goal_position:
                        state_idx = (state[0], state[1], goal[0], goal[1])
                        next_state_idx = (next_state[0], next_state[1], goal[0], goal[1])
                    else:
                        state_idx = (state[0], state[1])
                        next_state_idx = (next_state[0], next_state[1])

                # Actualizar la tabla Q con Q-learning
                max_next_q = np.max(self.Q[next_state_idx])
                td_target = reward + self.gamma * max_next_q
                td_error = td_target - self.Q[state_idx][action]
                self.Q[state_idx][action] += self.alpha * td_error

                state = next_state  # Actualizar el estado actual
                total_reward += reward  # Acumular recompensa
                
                # Terminar el episodio si se excede el límite de acciones
                if nactions >= self.max_actions_per_episode:
                    done = True
                
                # Renderizar si el flag está activado
                if self.render_training:
                    if not self.env.render():  # Renderizar el entorno
                        print("Visualización detenida por el usuario durante entrenamiento.")
                        return rewards_per_episode  # Salir del entrenamiento si se cierra la ventana

            # Contar episodios exitosos (cuando se obtiene recompensa positiva)
            if total_reward > 0:
                successful_episodes += 1
            
            rewards_per_episode.append(total_reward)  # Almacenar recompensa total del episodio
            
            # Actualizar epsilon y contador de episodios
            self.current_episode += 1
            self._update_epsilon(num_episodes)

        # Imprimir estadísticas finales
        total_reward_sum = sum(rewards_per_episode)
        print(f"\n=== Estadísticas de Entrenamiento ===")
        print(f"Episodios exitosos: {successful_episodes}/{num_episodes} ({100*successful_episodes/num_episodes:.2f}%)")
        print(f"Recompensa total acumulada: {total_reward_sum}")
        print(f"Recompensa promedio por episodio: {total_reward_sum/num_episodes:.4f}")
        
        return rewards_per_episode  # Devolver las recompensas por episodio

    def train_sarsa(self, num_episodes):
        rewards_per_episode = []  # Lista para almacenar recompensas por episodio

        for episode in range(num_episodes):
            if self.frozen_env:
                state, info = self.env.reset()  # FrozenLake devuelve (state, info)
            else:
                state = self.env.reset()  # Environment2D devuelve solo state
            action = self.choose_action(state)  # Elegir acción
            done = False
            total_reward = 0  # Recompensa total para este episodio

            while not done:
                if self.frozen_env:
                    next_state, reward, done, truncated, info = self.env.step(action)
                else:
                    next_state, reward, done = self.env.step(action)  # Realizar acción
                
                # Aplicar recompensa basada en distancia si está activado (solo para Environment2D)
                if not self.frozen_env:
                    reward = self._get_distance_reward(state, next_state, reward, done)
                
                total_reward += reward  # Acumular recompensa
                next_action = self.choose_action(next_state)  # Elegir la siguiente acción
                
                # Actualizar la tabla Q según si se usa posición del objetivo
                if self.frozen_env:
                    # Para FrozenLake, el estado es un entero
                    self.Q[state, action] += self.alpha * (
                        reward + self.gamma * self.Q[next_state, next_action] - 
                        self.Q[state, action]
                    )
                else:
                    goal = self.env.goal
                    if self.use_goal_position:
                        # Con posición del objetivo: incluir posición del objetivo en el estado
                        self.Q[state[0], state[1], goal[0], goal[1], action] += self.alpha * (
                            reward + self.gamma * self.Q[next_state[0], next_state[1], goal[0], goal[1], next_action] - 
                            self.Q[state[0], state[1], goal[0], goal[1], action]
                        )
                    else:
                        # Sin posición del objetivo: solo usar posición del agente
                        self.Q[state[0], state[1], action] += self.alpha * (
                            reward + self.gamma * self.Q[next_state[0], next_state[1], next_action] - 
                            self.Q[state[0], state[1], action]
                        )
                
                state, action = next_state, next_action  # Avanzar al siguiente estado y acción

                # Renderizar si el flag está activado
                if self.render_training:
                    if not self.env.render():  # Renderizar el entorno
                        print("Visualización detenida por el usuario durante entrenamiento.")
                        return rewards_per_episode  # Salir del entrenamiento si se cierra la ventana

            rewards_per_episode.append(total_reward)  # Almacenar recompensa total del episodio
            
            # Actualizar epsilon y contador de episodios
            self.current_episode += 1
            self._update_epsilon(num_episodes)

        return rewards_per_episode  # Devolver las recompensas por episodio

    def test_agent(self, num_tests):
        """Ejecuta pruebas del agente después de haber aprendido."""
        successes = 0
        for test in range(num_tests):
            observation, info = self.env.reset()  # Gymnasium devuelve (observation, info)
            state = observation
            terminated = False
            truncated = False
            total_reward = 0
            steps = 0
            print(f"\nPrueba {test + 1}:")

            while not (terminated or truncated) and steps < self.max_actions_per_episode:
                action = self.choose_action(state)  # Elegir acción basada en Q
                # Gymnasium devuelve (observation, reward, terminated, truncated, info)
                next_observation, reward, terminated, truncated, info = self.env.step(action)
                next_state = next_observation
                total_reward += reward
                state = next_state  # Avanzar al siguiente estado
                steps += 1
                # Renderizar el entorno después de cada acción
                self.env.render()  # Renderizar el entorno

            if total_reward > 0:
                successes += 1
                print(f"  ✓ Éxito! Recompensa: {total_reward}, Pasos: {steps}")
            else:
                print(f"  ✗ Fallo. Pasos: {steps}")

        print(f"\nResumen: {successes}/{num_tests} pruebas exitosas ({100*successes/num_tests:.1f}%)")
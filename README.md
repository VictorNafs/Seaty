Seaty - App de Réservation de Véhicules

Description

Seaty est une application de réservation de véhicules basée sur un site e-commerce modifié. L'application permet aux utilisateurs de parcourir les véhicules disponibles, de les ajouter à leur panier, et de finaliser leur réservation. Cependant, elle présente encore quelques bugs connus, notamment des problèmes de panier persistant et des erreurs nécessitant un redémarrage du serveur.

Fonctionnalités

- Parcourir les véhicules disponibles
- Ajouter des véhicules au panier
- Finaliser les réservations

Problèmes connus

- Les bugs disparaissent temporairement après le redémarrage du serveur.
- Les véhicules réservés ne sont pas retirés des paniers des autres utilisateurs après l'achat.

Installation

Pour installer et configurer cette application sur votre machine locale, suivez ces étapes :

Clonez le dépôt :

- "git clone git@github.com:VictorNafs/Seaty.git"
- "cd Seaty"

Installez les dépendances nécessaires :

- "bundle install"

Créez et configurez la base de données :

- "rails db:create"
- "rails db:migrate"
- "rails db:seed"

Démarrez le serveur Rails :

- "rails server"

Accédez à l'application via http://localhost:3000 dans votre navigateur.

Contributions

Toute aide pour corriger les bugs ou améliorer les fonctionnalités est la bienvenue ! Si vous souhaitez contribuer :

Contactez moi : cmoikvolelorange@gmail.com
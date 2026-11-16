import Foundation

public enum SampleRecipes {
    public static let all: [Recipe] = [
        Recipe(
            name: "Gratin Dauphinois traditionnel",
            image: "https://images.unsplash.com/photo-1598515214211-89d3c73ae83b",
            category: "Plat",
            area: "French",
            ingredients: [
                Ingredient(name: "Pommes de terre", quantity: 800, unit: "g"),
                Ingredient(name: "Crème liquide", quantity: 200, unit: "ml"),
                Ingredient(name: "Lait entier", quantity: 200, unit: "ml"),
                Ingredient(name: "Ail", quantity: 2, unit: "gousses"),
                Ingredient(name: "Muscade", quantity: 1, unit: "pincée")
            ],
            instructions: ["Éplucher les pommes de terre", "Couper en rondelles fines", "Cuire au four 50 min à 180°C"],
            preparationTime: 45,
            calories: 520,
            proteins: 12,
            carbohydrates: 54,
            fats: 28,
            tags: ["Végétarien", "Comfort Food", "Gratin"]
        ),
        Recipe(
            name: "Salade César au poulet grillé",
            image: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd",
            category: "Chicken",
            area: "American",
            ingredients: [
                Ingredient(name: "Blanc de poulet", quantity: 250, unit: "g"),
                Ingredient(name: "Salade romaine", quantity: 150, unit: "g"),
                Ingredient(name: "Parmesan", quantity: 30, unit: "g"),
                Ingredient(name: "Croûtons de pain", quantity: 30, unit: "g"),
                Ingredient(name: "Sauce césar", quantity: 2, unit: "c. à soupe")
            ],
            instructions: ["Griller le poulet à la poêle", "Émincer la salade", "Mélanger avec les croûtons et le parmesan"],
            preparationTime: 20,
            calories: 480,
            proteins: 42,
            carbohydrates: 18,
            fats: 24,
            tags: ["High Protein", "Salade", "Rapide"]
        ),
        Recipe(
            name: "Pavé de saumon et poêlée de légumes verts",
            image: "https://images.unsplash.com/photo-1467003909585-2f8a72700288",
            category: "Seafood",
            area: "French",
            ingredients: [
                Ingredient(name: "Pavé de saumon", quantity: 200, unit: "g"),
                Ingredient(name: "Courgettes", quantity: 200, unit: "g"),
                Ingredient(name: "Brocolis", quantity: 150, unit: "g"),
                Ingredient(name: "Huile d'olive", quantity: 1, unit: "c. à soupe"),
                Ingredient(name: "Citron", quantity: 0.5, unit: "pièce")
            ],
            instructions: ["Poêler le saumon côté peau", "Cuire les légumes à la vapeur", "Arroser de citron"],
            preparationTime: 25,
            calories: 510,
            proteins: 38,
            carbohydrates: 12,
            fats: 32,
            tags: ["Pescétarien", "Omega 3", "Healthy"]
        ),
        Recipe(
            name: "Bowl végétarien au quinoa et avocat",
            image: "https://images.unsplash.com/photo-1540420773420-3366772f4999",
            category: "Vegetarian",
            area: "Mediterranean",
            ingredients: [
                Ingredient(name: "Quinoa", quantity: 120, unit: "g"),
                Ingredient(name: "Avocat", quantity: 1, unit: "pièce"),
                Ingredient(name: "Pois chiches", quantity: 150, unit: "g"),
                Ingredient(name: "Tomates cerises", quantity: 100, unit: "g"),
                Ingredient(name: "Huile d'olive", quantity: 1, unit: "c. à soupe")
            ],
            instructions: ["Cuire le quinoa 12 min", "Dresser avec l'avocat tranché et les pois chiches"],
            preparationTime: 20,
            calories: 540,
            proteins: 18,
            carbohydrates: 62,
            fats: 22,
            tags: ["Végétarien", "Végan", "Bowl", "Fibre"]
        ),
        Recipe(
            name: "Pâtes à la bolognaise mijotée",
            image: "https://images.unsplash.com/photo-1621996346565-e3d5d6281699",
            category: "Beef",
            area: "Italian",
            ingredients: [
                Ingredient(name: "Pâtes spaghetti", quantity: 160, unit: "g"),
                Ingredient(name: "Bœuf haché 5%", quantity: 200, unit: "g"),
                Ingredient(name: "Sauce tomate", quantity: 250, unit: "g"),
                Ingredient(name: "Oignon", quantity: 1, unit: "pièce"),
                Ingredient(name: "Origan", quantity: 1, unit: "c. à café")
            ],
            instructions: ["Faire revenir l'oignon et la viande", "Ajouter la sauce tomate", "Servir chaud sur les pâtes"],
            preparationTime: 30,
            calories: 610,
            proteins: 40,
            carbohydrates: 70,
            fats: 16,
            tags: ["Italienne", "Pâtes", "Familial"]
        ),
        Recipe(
            name: "Dahl de lentilles corail au lait de coco",
            image: "https://images.unsplash.com/photo-1546833999-b9f581a1996d",
            category: "Vegetarian",
            area: "Indian",
            ingredients: [
                Ingredient(name: "Lentilles corail", quantity: 180, unit: "g"),
                Ingredient(name: "Lait de coco", quantity: 150, unit: "ml"),
                Ingredient(name: "Tomates concassées", quantity: 200, unit: "g"),
                Ingredient(name: "Curry en poudre", quantity: 1, unit: "c. à soupe"),
                Ingredient(name: "Gingembre frais", quantity: 10, unit: "g")
            ],
            instructions: ["Rincer les lentilles", "Mijoter dans le lait de coco et tomates avec les épices 20 min"],
            preparationTime: 25,
            calories: 460,
            proteins: 22,
            carbohydrates: 55,
            fats: 14,
            tags: ["Végétarien", "Végan", "Indienne", "Sans gluten"]
        ),
        Recipe(
            name: "Risotto crémeux aux champignons",
            image: "https://images.unsplash.com/photo-1633964913295-ceb43826e7c9",
            category: "Vegetarian",
            area: "Italian",
            ingredients: [
                Ingredient(name: "Riz Arborio", quantity: 160, unit: "g"),
                Ingredient(name: "Champignons de Paris", quantity: 200, unit: "g"),
                Ingredient(name: "Bouillon de légumes", quantity: 500, unit: "ml"),
                Ingredient(name: "Parmesan râpé", quantity: 40, unit: "g"),
                Ingredient(name: "Échalote", quantity: 1, unit: "pièce")
            ],
            instructions: ["Faire suer l'échalote", "Nacrer le riz", "Verser le bouillon louche après louche pendant 18 min"],
            preparationTime: 35,
            calories: 530,
            proteins: 16,
            carbohydrates: 74,
            fats: 15,
            tags: ["Italienne", "Végétarien", "Risotto"]
        ),
        Recipe(
            name: "Poulet teriyaki et riz jasmin",
            image: "https://images.unsplash.com/photo-1598514982205-f36b96d1e8d4",
            category: "Chicken",
            area: "Japanese",
            ingredients: [
                Ingredient(name: "Blancs de poulet", quantity: 250, unit: "g"),
                Ingredient(name: "Sauce soja", quantity: 3, unit: "c. à soupe"),
                Ingredient(name: "Miel", quantity: 1, unit: "c. à soupe"),
                Ingredient(name: "Riz jasmin", quantity: 150, unit: "g"),
                Ingredient(name: "Graines de sésame", quantity: 1, unit: "c. à café")
            ],
            instructions: ["Caraméliser le poulet dans la sauce teriyaki", "Cuire le riz jasmin", "Parsemer de sésame"],
            preparationTime: 25,
            calories: 560,
            proteins: 44,
            carbohydrates: 65,
            fats: 11,
            tags: ["Asiatique", "High Protein", "Rapide"]
        ),
        Recipe(
            name: "Ratatouille provençale et riz complet",
            image: "https://images.unsplash.com/photo-1572449043416-55f4685c9bb7",
            category: "Vegetarian",
            area: "French",
            ingredients: [
                Ingredient(name: "Courgettes", quantity: 200, unit: "g"),
                Ingredient(name: "Aubergines", quantity: 200, unit: "g"),
                Ingredient(name: "Poivrons rouges", quantity: 150, unit: "g"),
                Ingredient(name: "Tomates", quantity: 200, unit: "g"),
                Ingredient(name: "Huile d'olive", quantity: 2, unit: "c. à soupe")
            ],
            instructions: ["Couper les légumes en dés", "Mijoter à feu doux 35 min avec les herbes de Provence"],
            preparationTime: 45,
            calories: 390,
            proteins: 10,
            carbohydrates: 52,
            fats: 14,
            tags: ["Végétarien", "Végan", "Française", "Healthy", "Sans gluten"]
        ),
        Recipe(
            name: "Tacos mexicains au bœuf épicé",
            image: "https://images.unsplash.com/photo-1551504734-5ee1c4a1479b",
            category: "Beef",
            area: "Mexican",
            ingredients: [
                Ingredient(name: "Galettes de maïs", quantity: 4, unit: "pièces"),
                Ingredient(name: "Viande hachée", quantity: 200, unit: "g"),
                Ingredient(name: "Épices chili", quantity: 1, unit: "c. à café"),
                Ingredient(name: "Avocat", quantity: 0.5, unit: "pièce"),
                Ingredient(name: "Coriandre fraîche", quantity: 5, unit: "brins")
            ],
            instructions: ["Cuire la viande avec les épices", "Garnir les galettes réchauffées avec avocat et herbes"],
            preparationTime: 20,
            calories: 590,
            proteins: 36,
            carbohydrates: 48,
            fats: 26,
            tags: ["Mexicaine", "Convivial", "Rapide"]
        ),
        Recipe(
            name: "Filet de cabillaud en papillote au citron",
            image: "https://images.unsplash.com/photo-1534939561126-855b8675edd7",
            category: "Seafood",
            area: "French",
            ingredients: [
                Ingredient(name: "Filet de cabillaud", quantity: 220, unit: "g"),
                Ingredient(name: "Tomates cerises", quantity: 100, unit: "g"),
                Ingredient(name: "Courgettes", quantity: 150, unit: "g"),
                Ingredient(name: "Huile d'olive", quantity: 1, unit: "c. à café"),
                Ingredient(name: "Aneth frais", quantity: 2, unit: "brins")
            ],
            instructions: ["Disposer le poisson et les légumes sur le papier cuisson", "Cuire au four 20 min à 190°C"],
            preparationTime: 25,
            calories: 340,
            proteins: 42,
            carbohydrates: 8,
            fats: 12,
            tags: ["Pescétarien", "Healthy", "Léger", "Sans gluten"]
        ),
        Recipe(
            name: "Omelette printanière aux épinards et chèvre",
            image: "https://images.unsplash.com/photo-1510693206972-df098062cb71",
            category: "Vegetarian",
            area: "French",
            ingredients: [
                Ingredient(name: "Œufs entiers", quantity: 3, unit: "pièces"),
                Ingredient(name: "Jeunes pousses d'épinards", quantity: 100, unit: "g"),
                Ingredient(name: "Fromage de chèvre frais", quantity: 40, unit: "g"),
                Ingredient(name: "Beurre", quantity: 10, unit: "g")
            ],
            instructions: ["Faire tomber les épinards", "Battre les œufs et cuire à la poêle", "Ajouter le chèvre au centre"],
            preparationTime: 15,
            calories: 380,
            proteins: 24,
            carbohydrates: 4,
            fats: 28,
            tags: ["Végétarien", "Keto", "Rapide", "Sans gluten"]
        ),
        Recipe(
            name: "Curry thaï de légumes et tofu croustillant",
            image: "https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd",
            category: "Vegetarian",
            area: "Thai",
            ingredients: [
                Ingredient(name: "Tofu ferme", quantity: 200, unit: "g"),
                Ingredient(name: "Pâte de curry vert", quantity: 1, unit: "c. à soupe"),
                Ingredient(name: "Lait de coco", quantity: 200, unit: "ml"),
                Ingredient(name: "Poivrons", quantity: 100, unit: "g"),
                Ingredient(name: "Riz basmati", quantity: 120, unit: "g")
            ],
            instructions: ["Dorer le tofu en dés", "Porter le curry et le coco à frémissement", "Ajouter les légumes"],
            preparationTime: 25,
            calories: 530,
            proteins: 22,
            carbohydrates: 56,
            fats: 22,
            tags: ["Asiatique", "Végétarien", "Végan", "Sans gluten"]
        ),
        Recipe(
            name: "Salade grecque traditionnelle à la feta",
            image: "https://images.unsplash.com/photo-1540420773420-3366772f4999",
            category: "Vegetarian",
            area: "Greek",
            ingredients: [
                Ingredient(name: "Fromage feta", quantity: 120, unit: "g"),
                Ingredient(name: "Concombre", quantity: 1, unit: "pièce"),
                Ingredient(name: "Tomates mûres", quantity: 2, unit: "pièces"),
                Ingredient(name: "Olives de Kalamata", quantity: 40, unit: "g"),
                Ingredient(name: "Huile d'olive extra vierge", quantity: 2, unit: "c. à soupe")
            ],
            instructions: ["Découper légumes et feta en cubes", "Assaisonner d'huile et d'origan"],
            preparationTime: 15,
            calories: 440,
            proteins: 18,
            carbohydrates: 12,
            fats: 34,
            tags: ["Méditerranéenne", "Végétarien", "Sans cuisson", "Sans gluten"]
        ),
        Recipe(
            name: "Chili con carne express aux haricots rouges",
            image: "https://images.unsplash.com/photo-1543339308-43e59d6b73a6",
            category: "Beef",
            area: "Mexican",
            ingredients: [
                Ingredient(name: "Viande hachée de bœuf", quantity: 200, unit: "g"),
                Ingredient(name: "Haricots rouges égouttés", quantity: 200, unit: "g"),
                Ingredient(name: "Coulis de tomates", quantity: 200, unit: "g"),
                Ingredient(name: "Maïs doux", quantity: 80, unit: "g"),
                Ingredient(name: "Cumin moulu", quantity: 1, unit: "c. à café")
            ],
            instructions: ["Faire dorer la viande", "Ajouter les haricots, le maïs et la sauce tomate", "Mijoter 20 min"],
            preparationTime: 25,
            calories: 560,
            proteins: 44,
            carbohydrates: 52,
            fats: 16,
            tags: ["Mexicaine", "High Protein", "Fibre"]
        ),
        Recipe(
            name: "Wok de crevettes sautées aux nouilles",
            image: "https://images.unsplash.com/photo-1569718212165-3a8278d5f624",
            category: "Seafood",
            area: "Asian",
            ingredients: [
                Ingredient(name: "Crevettes décortiquées", quantity: 200, unit: "g"),
                Ingredient(name: "Nouilles de blé", quantity: 140, unit: "g"),
                Ingredient(name: "Carottes râpées", quantity: 100, unit: "g"),
                Ingredient(name: "Sauce soja", quantity: 2, unit: "c. à soupe"),
                Ingredient(name: "Huile de sésame", quantity: 1, unit: "c. à café")
            ],
            instructions: ["Cuire les nouilles 4 min", "Sauter les crevettes et légumes au wok", "Mélanger avec la sauce"],
            preparationTime: 20,
            calories: 510,
            proteins: 34,
            carbohydrates: 62,
            fats: 12,
            tags: ["Pescétarien", "Asiatique", "Wok", "Rapide"]
        )
    ]
}

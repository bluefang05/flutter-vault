# Shop Asset Catalog

Este catálogo define cómo nombrar y producir assets de ropa y accesorios para Grapa.

## Convención

- `item_id`: identificador estable para guardar compras y desbloqueos.
- `tipo`: clase de prenda o accesorio.
- `estilo`: descriptor visual corto.
- `color`: paleta dominante.
- `formatos`: variantes esperadas por uso.

## Paquete base actual

- `dress_premium_01`: vestido premium, morado y dorado.
- `bow_premium_01`: lazo premium, morado y dorado.
- `hat_premium_01`: sombrero premium, morado y dorado.
- `backpack_premium_01`: mochila premium, morado y dorado.

## Siguientes familias recomendadas

- `dress_casual_01`: vestido casual.
- `dress_elegant_01`: vestido elegante.
- `jacket_city_01`: chaqueta urbana.
- `hoodie_cozy_01`: sudadera cómoda.
- `season_summer_01`: variante de temporada.
- `season_winter_01`: variante de temporada.

## Archivos por item

Para cada item conviene generar:

- `icon`: icono para inventario o tienda.
- `shop_card`: imagen para tarjeta de tienda.
- `equipped`: ilustración del personaje con la prenda puesta.
- `color_variant`: variante si el artículo admite colores.

## Equipped assets actuales

- `dress_premium_01`: `assets/images/grapa_equipped/grapa_equipped_dress_premium_01.png`
- `dress_casual_01`: `assets/images/grapa_equipped/grapa_equipped_dress_casual_01.png`
- `dress_elegant_01`: `assets/images/grapa_equipped/grapa_equipped_dress_elegant_01.png`
- `jacket_cozy_01`: `assets/images/grapa_equipped/grapa_equipped_jacket_cozy_01.png`
- `scarf_winter_01`: `assets/images/grapa_equipped/grapa_equipped_scarf_winter_01.png`
- `bow_premium_01`: `assets/images/grapa_equipped/grapa_equipped_bow_premium_01.png`
- `hat_premium_01`: `assets/images/grapa_equipped/grapa_equipped_hat_premium_01.png`
- `backpack_premium_01`: `assets/images/grapa_equipped/grapa_equipped_backpack_premium_01.png`

## Reglas

- Mantener fondo transparente en assets reutilizables.
- Mantener proporciones consistentes entre prendas.
- Usar nombres sin espacios y con sufijos estables.
- Evitar duplicar estilos si el item ya existe en otra variante.

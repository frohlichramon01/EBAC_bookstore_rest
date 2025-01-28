from django.test import TestCase

from product.factories import CategoryFactory, ProductFactory
from product.serializers import ProductSerializer


class TestProductSerializer(TestCase):
    def setUp(self) -> None:
        self.category = CategoryFactory(title="Categoria1")
        self.product_1 = ProductFactory(
            title="garrafa de agua", price=50, category=[self.category]
        )
        self.product_serializer = ProductSerializer(self.product_1)

    def test_product_serializer(self):
        serializer_data = self.product_serializer.data
        self.assertEqual(serializer_data["price"], 50)
        self.assertEqual(serializer_data["title"], "garrafa de agua")
        self.assertEqual(serializer_data["category"][0]["title"], "Categoria1")

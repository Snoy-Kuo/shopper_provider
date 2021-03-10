// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shopper_provider/models/cart.dart';
import 'package:shopper_provider/models/catalog.dart';
import 'package:shopper_provider/screens/cart.dart';

CartModel? cartModel;
CatalogModel? catalogModel;

Widget createCartScreen() => MultiProvider(
      providers: [
        Provider(create: (context) => CatalogModel()),
        ChangeNotifierProxyProvider<CatalogModel, CartModel>(
          create: (context) => CartModel(),
          update: (context, catalog, cart) {
            catalogModel = catalog;
            cartModel = cart;
            cart!.catalog = catalogModel!;
            return cart;
          },
        ),
      ],
      child: MaterialApp(
        home: MyCart(),
      ),
    );

void main() {
  group('CartScreen widget tests', () {
    testWidgets('Empty cart displays empty placeholder.', (tester) async {
      await tester.pumpWidget(createCartScreen());

      // Verify no BUY button initially exists.
      expect(find.text('BUY'), findsNothing);

      // Verifying the placeholder visible.
      expect(find.text('Nothing in the cart..'), findsOneWidget);
    });

    testWidgets('Tapping BUY button displays snackbar.', (tester) async {
      await tester.pumpWidget(createCartScreen());

      // Adding one item in the cart and testing.
      var item = catalogModel!.getByPosition(0);
      cartModel!.add(item);
      await tester.pumpAndSettle();
      expect(find.text(item.name), findsOneWidget);

      // Verify no snackbar initially exists.
      expect(find.byType(SnackBar), findsNothing);
      await tester.tap(find.text('BUY'));
      // Schedule animation.
      await tester.pump();
      // Verifying the snackbar upon clicking the button.
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Testing when the cart contains items', (tester) async {
      await tester.pumpWidget(createCartScreen());

      // Adding two items in the cart and testing.
      for (var i = 0; i < 2; i++) {
        var item = catalogModel!.getByPosition(i);
        cartModel!.add(item);
        await tester.pumpAndSettle();
        expect(find.text(item.name), findsOneWidget);
      }

      // Testing total price of the first two items.
      expect(find.text('\$${(56+57)}'), findsOneWidget);
      expect(find.byIcon(Icons.done), findsNWidgets(2));
    });
  });
}

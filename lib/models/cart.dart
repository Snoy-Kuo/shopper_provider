// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:shopper_provider/models/catalog.dart';

class CartModel extends ChangeNotifier {
  /// The private field backing [catalog].
  late CatalogModel _catalog;

  /// Internal, private state of the cart. Stores the ids of each item.
  final LinkedHashMap<int, int> _itemIdVols = LinkedHashMap();

  /// The current catalog. Used to construct items from numeric ids.
  CatalogModel get catalog => _catalog;

  set catalog(CatalogModel newCatalog) {
    _catalog = newCatalog;
    // Notify listeners, in case the new catalog provides information
    // different from the previous one. For example, availability of an item
    // might have changed.
    notifyListeners();
  }

  /// List of items in the cart.
  List<CartItem> get items => _itemIdVols.entries
      .map((entry) => CartItem(_catalog.getById(entry.key), entry.value))
      .toList();

  /// The current total price of all items.
  int get totalPrice => items.fold(
      0, (total, current) => total + current.info.price * current.volume);

  /// Adds [item] to cart. This is the only way to modify the cart from outside.
  void add(Item item) {
    if (_itemIdVols[item.id] != null) {
      _itemIdVols[item.id] = _itemIdVols[item.id]! + 1;
    } else {
      _itemIdVols[item.id] = 1;
    }
    // This line tells [Model] that it should rebuild the widgets that
    // depend on it.
    notifyListeners();
  }

  void remove(Item item) {
    if (_itemIdVols[item.id] != null) {
      if (_itemIdVols[item.id]! > 1) {
        _itemIdVols[item.id] = _itemIdVols[item.id]! - 1;
      } else {
        _itemIdVols.remove(item.id);
      }
    }
    // Don't forget to tell dependent widgets to rebuild _every time_
    // you change the model.
    notifyListeners();
  }

  ///contains item
  int contains(Item info) {
    if (null == _itemIdVols[info.id]) return 0;

    return _itemIdVols[info.id]!;
  }
}

class CartItem {
  final Item info;
  int volume = 0;

  CartItem(this.info, this.volume);

  void increment() {
    volume += 1;
  }

  void decrement() {
    if (volume > 0) {
      volume -= 1;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProdScreen extends StatefulWidget {
  static const route = '/edit';
  @override
  _EditProdScreenState createState() => _EditProdScreenState();
}

class _EditProdScreenState extends State<EditProdScreen> {
  final isInit = true;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  bool _isLoading = false;
  final _priceFocusNode = FocusNode();
  final _descFocus = FocusNode();
  final _imageURLController = TextEditingController();
  final _imageFocusNode = FocusNode(); //to load image on change focus
  final _formKey = GlobalKey<FormState>();
  var _editedProd =
      Product(id: null, title: '', description: '', imageUrl: '', price: 0);

  void _updateImage() {
    if (!_imageFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProd.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProd(_editedProd.id, _editedProd);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProd);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Something went wrong'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Okay'),
              )
            ],
          ),
        );
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    _imageFocusNode.addListener(_updateImage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String?;
      if (productId == null) {
        return;
      }
      _editedProd =
          Provider.of<Products>(context, listen: false).findById(productId);
    }
    _initValues = {
      'title': _editedProd.title,
      'description': _editedProd.description,
      'price': _editedProd.price.toString(),
      'imageUrl': ''
    };
    _imageURLController.text = _editedProd.imageUrl;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    //dispose nodes to clear from memory
    _priceFocusNode.dispose();
    _descFocus.dispose();
    _imageURLController.dispose();
    _imageFocusNode.removeListener(_updateImage);
    _imageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Product'),
          actions: [
            IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          initialValue: _initValues['title'],
                          decoration:
                              const InputDecoration(labelText: 'Title :'),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (value) {
                            FocusScope.of(context)
                                .requestFocus(_priceFocusNode);
                          },
                          validator: (value) {
                            //
                            if (value!.isEmpty) {
                              return 'Empty ';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _editedProd = Product(
                                id: _editedProd.id,
                                title: newValue ?? '',
                                description: _editedProd.description,
                                imageUrl: _editedProd.imageUrl,
                                price: _editedProd.price,
                                isFavorite: _editedProd.isFavorite);
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['price'],
                          decoration: const InputDecoration(labelText: 'Price'),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          focusNode: _priceFocusNode,
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(_descFocus);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter Price ';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter a valid Number';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Please enter a valid Number';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _editedProd = Product(
                                isFavorite: _editedProd.isFavorite,
                                id: _editedProd.id,
                                title: _editedProd.title,
                                description: _editedProd.description,
                                imageUrl: _editedProd.imageUrl,
                                price: double.parse(newValue!));
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['description'],
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          decoration:
                              const InputDecoration(labelText: 'Description'),
                          //  textInputAction: TextInputAction.next,

                          focusNode: _descFocus,
                          validator: (value) {
                            //
                            if (value!.isEmpty) {
                              return 'Empty ';
                            }
                            if (value.length <= 10) {
                              return 'Short Description';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _editedProd = Product(
                                isFavorite: _editedProd.isFavorite,
                                id: _editedProd.id,
                                title: _editedProd.title,
                                description: newValue ?? '',
                                imageUrl: _editedProd.imageUrl,
                                price: _editedProd.price);
                          },
                        ),
                        Row(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: EdgeInsets.only(top: 8, right: 10),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                              ),
                              child: _imageURLController.text.isEmpty
                                  ? Text('Enter Url')
                                  : Image.network(
                                      _imageURLController.text,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Expanded(
                              child: TextFormField(
                                //  initialValue: _initValues['imageUrl'],
                                decoration: const InputDecoration(
                                    labelText: 'Image URL'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller: _imageURLController,
                                focusNode: _imageFocusNode,
                                onSaved: (newValue) {
                                  _editedProd = Product(
                                      isFavorite: _editedProd.isFavorite,
                                      id: _editedProd.id,
                                      title: _editedProd.title,
                                      description: _editedProd.description,
                                      imageUrl: newValue ?? '',
                                      price: _editedProd.price);
                                },
                                onFieldSubmitted: (_) {
                                  _saveForm();
                                },
                                validator: (value) {
                                  //
                                  if (value!.isEmpty) {
                                    return 'Empty ';
                                  }
                                  if (!value.startsWith('http') &&
                                      !value.startsWith('https')) {
                                    return 'Enter a valid Url';
                                  }
                                  return null;
                                },
                              ),
                            )
                          ],
                        )
                      ],
                    )),
              ));
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../view_models/admin&dealer/from_view_models/category_form_view_model.dart';

class ProductCategoryForm extends StatelessWidget {
  const ProductCategoryForm({super.key, required this.userId});
  final int userId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryFormViewModel(Repository(HttpService()))..getCategoryList(),
      child: Consumer<CategoryFormViewModel>(
        builder: (context, viewModel, _) {
          return Row(
            children: [
              Flexible(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        color: Colors.white,
                        child: ListTile(
                          title: Text('Product Category', style: Theme.of(context).textTheme.titleLarge),
                          subtitle: Text('Product Category with this details', style: Theme.of(context).textTheme.titleMedium),
                          trailing: Wrap(
                            spacing: 12, // space between two icons
                            children: <Widget>[
                              IconButton(
                                  tooltip: viewModel.editCategory ?'Done':'Edit or in-active category',
                                  onPressed: ()=>viewModel.productEditing(),
                                  icon: viewModel.editCategory ? Icon(Icons.done_all, color: Theme.of(context).primaryColor,) : Icon(Icons.edit_note_outlined, color: Theme.of(context).primaryColor,)),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor,),
                                tooltip: 'Add new category',
                                onPressed: () async {
                                  await showDialog<void>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        content: viewModel.showAddAndEditForm(context, false, userId, 0),
                                      ));
                                },
                              ), // icon-2
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                          child: GridView.builder(
                            itemCount: viewModel.categoryList.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsetsDirectional.all(5.0),
                                decoration: BoxDecoration(
                                  color: viewModel.categoryList[index].active=='1'? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.red.shade100,
                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                ),
                                child: ListTile(
                                  title: Text(viewModel.categoryList[index].categoryName,),
                                  trailing: viewModel.editCategory ? Wrap(
                                    spacing: 12,
                                    children: <Widget>[
                                      IconButton(onPressed: ()
                                      async {
                                        viewModel.catName.text = viewModel.categoryList[index].categoryName;
                                        viewModel.sldCatID = viewModel.categoryList[index].categoryId;
                                        await showDialog<void>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              content: viewModel.showAddAndEditForm(context, true, userId, viewModel.categoryList[index].categoryId),
                                            ));

                                      }, icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor,),),
                                      IconButton(onPressed: () =>viewModel.inactiveCategory(context, userId, viewModel.categoryList[index].categoryId,viewModel.categoryList[index].active),
                                          icon: viewModel.categoryList[index].active=='1'? const Icon(Icons.check_circle_outlined, color: Colors.green,):
                                          const Icon(Icons.unpublished_outlined, color: Colors.red,)),
                                    ],
                                  ): null,
                                ),
                              );
                            },
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: MediaQuery.sizeOf(context).width > 1200 ? 4 : 3,
                              childAspectRatio: MediaQuery.sizeOf(context).width > 1200 ? MediaQuery.sizeOf(context).width / 250 : MediaQuery.sizeOf(context).width / 150,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
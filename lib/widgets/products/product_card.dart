import 'package:flutter/material.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/utils/themes/app_colors.dart';

class ProductCard extends StatelessWidget {
  final ProductItem product;
  final String searchQuery;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback onManageBarcode;
  final VoidCallback onManagePrice;

  const ProductCard({
    super.key,
    required this.product,
    required this.searchQuery,
    required this.onViewDetails,
    required this.onEdit,
    required this.onManageBarcode,
    required this.onManagePrice,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isMediumScreen = MediaQuery.of(context).size.width < 768;
    final isLargeScreen = MediaQuery.of(context).size.width >= 768;

    return Card(
      elevation: 1,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 16,
        vertical: 4,
      ),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return _buildCompactLayout(context, isSmallScreen);
              } else if (constraints.maxWidth < 600) {
                return _buildMediumLayout(context, isMediumScreen);
              } else {
                return _buildExpandedLayout(context, isLargeScreen);
              }
            },
          ),
        ),
      ),
    );
  }

  // Compact layout for very small screens (mobile portrait)
  Widget _buildCompactLayout(BuildContext context, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row with status and title
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: product.disabled == 0 ? Colors.green : Colors.red,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductTitle(isSmallScreen),
                  // const SizedBox(height: 4),
                  // _buildProductCode(isSmallScreen),
                ],
              ),
            ),
            _buildOptionsMenu(context),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Middle section
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductGroup(isSmallScreen),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriceSection(isSmallScreen),
                  _buildStatusBadge(isSmallScreen),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Medium layout for tablets and larger phones
  Widget _buildMediumLayout(BuildContext context, bool isMediumScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Indicator
        Container(
          width: 5,
          height: 70,
          decoration: BoxDecoration(
            color: product.disabled == 0 ? Colors.green : Colors.red,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Main content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductTitle(isMediumScreen),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(child: _buildProductCode(isMediumScreen)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildProductGroup(isMediumScreen)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildOptionsMenu(context),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriceSection(isMediumScreen),
                  _buildStatusBadge(isMediumScreen),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Expanded layout for tablets in landscape and desktops
  Widget _buildExpandedLayout(BuildContext context, bool isLargeScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Indicator
        Container(
          width: 6,
          height: 80,
          decoration: BoxDecoration(
            color: product.disabled == 0 ? Colors.green : Colors.red,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              bottomLeft: Radius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Product Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductTitle(isLargeScreen),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildProductCode(isLargeScreen),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: _buildProductGroup(isLargeScreen),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildPriceSection(isLargeScreen),
                        const SizedBox(height: 4),
                        _buildStatusBadge(isLargeScreen),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  _buildOptionsMenu(context),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductTitle(bool isSmallScreen) {
    final fontSize = isSmallScreen ? 16.0 : 18.0;
    
    if (searchQuery.isNotEmpty &&
        product.itemName.toLowerCase().contains(searchQuery)) {
      return RichText(
        text: TextSpan(
          children: _highlightOccurrences(product.itemName, searchQuery),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Text(
        product.itemName,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _buildProductCode(bool isSmallScreen) {
    final iconSize = isSmallScreen ? 14.0 : 16.0;
    final fontSize = isSmallScreen ? 12.0 : 14.0;
    
    return Row(
      children: [
        Icon(
          Icons.code,
          color: Colors.grey.shade600,
          size: iconSize,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: searchQuery.isNotEmpty &&
                  product.itemCode.toLowerCase().contains(searchQuery)
              ? RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Code: ",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: fontSize,
                        ),
                      ),
                      ..._highlightOccurrences(
                        product.itemCode,
                        searchQuery,
                        isCode: true,
                      ),
                    ],
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : Text(
                  "Code: ${product.itemCode}",
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ],
    );
  }

  Widget _buildProductGroup(bool isSmallScreen) {
    final iconSize = isSmallScreen ? 14.0 : 16.0;
    final fontSize = isSmallScreen ? 12.0 : 14.0;
    
    return Row(
      children: [
        Icon(
          Icons.category,
          color: Colors.grey.shade600,
          size: iconSize,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: searchQuery.isNotEmpty &&
                  product.itemGroup.toLowerCase().contains(searchQuery)
              ? RichText(
                  text: TextSpan(
                    children: [
                      // TextSpan(
                      //   text: "Group: ",
                      //   style: TextStyle(
                      //     color: Colors.grey,
                      //     fontSize: fontSize,
                      //   ),
                      // ),
                      ..._highlightOccurrences(
                        product.itemGroup,
                        searchQuery,
                        isCode: false,
                      ),
                    ],
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : Text(
                  product.itemGroup,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(bool isSmallScreen) {
    final priceFontSize = isSmallScreen ? 14.0 : 16.0;
    final uomFontSize = isSmallScreen ? 10.0 : 12.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KES ${product.standardRate}',
          style: TextStyle(
            fontSize: priceFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          product.stockUom,
          style: TextStyle(
            fontSize: uomFontSize,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isSmallScreen) {
    final fontSize = isSmallScreen ? 10.0 : 12.0;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: product.disabled == 0 ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: product.disabled == 0 ? Colors.green.shade200 : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Text(
        product.disabled == 0 ? 'Active' : 'Disabled',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: product.disabled == 0 ? Colors.green.shade800 : Colors.red.shade800,
        ),
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey,
        size: isSmallScreen ? 20 : 24,
      ),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onSelected: (value) {
        switch (value) {
          case 'view':
            onViewDetails();
            break;
          case 'edit':
            onEdit();
            break;
          case 'barcode':
            onManageBarcode();
            break;
          case 'price':
            onManagePrice();
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'view',
            child: Row(
              children: [
                const Icon(Icons.visibility, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('View Details'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                const Icon(Icons.edit, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('Edit'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'barcode',
            child: Row(
              children: [
                const Icon(Icons.qr_code, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Manage Barcode'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'price',
            child: Row(
              children: [
                const Icon(Icons.attach_money, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                const Text('Manage Price'),
              ],
            ),
          ),
        ];
      },
    );
  }
  List<TextSpan> _highlightOccurrences(
    String source,
    String query, {
    bool isCode = false,
  }) {
    if (query.isEmpty) return [TextSpan(text: source)];

    final matches = query.allMatches(source.toLowerCase());
    if (matches.isEmpty) return [TextSpan(text: source)];

    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: source.substring(lastMatchEnd, match.start)));
      }

      spans.add(
        TextSpan(
          text: source.substring(match.start, match.end),
          style: const TextStyle(
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );

      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < source.length) {
      spans.add(TextSpan(text: source.substring(lastMatchEnd)));
    }

    return spans;
  }
}
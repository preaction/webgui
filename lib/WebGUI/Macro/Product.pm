package WebGUI::Macro::Product;

use strict;
use WebGUI::Session;
use WebGUI::Product;
use WebGUI::Asset::Template;
use WebGUI::SQL;
use WebGUI::International;

=head1 NAME

Package WebGUI::Macro::Product

=head1 DESCRIPTION

This macro looks up a Product in the Product Manager 

=head2 process ( ID/SKU [,templateId] )

=head3 productId or SKU

The productId or SKU of the project to look up.

=head3 templateId

An alternate template to use for formatting the link, referenced by templateId.  If this
is left blank, a default template from the Macro/Product namespace will be used.

=cut

sub process {
	my (@param, $productId, $variantId, $product, $variant, $output, $templateId, @variantLoop, %var);
	
	@param = @_;
	
	return WebGUI::International::get('no sku or id') unless ($_[0]);

	($productId, $variantId) = WebGUI::SQL->quickArray("select productId, variantId from productVariants where sku=".quote($_[0]));
	($productId) = WebGUI::SQL->quickArray("select productId from products where sku=".quote($_[0])) unless ($productId);
	($productId) = WebGUI::SQL->quickArray("select productId from products where productId=".quote($_[0])) unless ($productId);
	
	return WebGUI::International::get('cannot find product','Macro_Product') unless ($productId);

	$product = WebGUI::Product->new($productId);

	if ($variantId) {
		$variant = [ $product->getVariant($variantId) ];
	} else {
		$variant = $product->getVariant;
	};
		
	foreach (@$variant) {
		my @compositionLoop;
		foreach (split(/,/,$_->{composition})) {
			my ($parameterId, $optionId) = split(/\./, $_);
			push(@compositionLoop, {
				parameter 	=> $product->getParameter($parameterId)->{name},
				value		=> $product->getOption($optionId)->{value}
			});
		}

		push (@variantLoop, {
			'variant.variantId' => $_->{variantId},
		        'variant.price' => $_->{price},
			'variant.weight' => $_->{weight},
			'variant.sku' => $_->{sku},
			'variant.compositionLoop' => \@compositionLoop,
			'variant.addToCart.url' => WebGUI::URL::page('op=addToCart;itemType=Product;itemId='.$_->{variantId}),
			'variant.addToCart.label' => WebGUI::International::get('add to cart', 'Macro_Product'),
		}) if ($_->{available});
	}

	%var = %{$product->get};
	$var{variantLoop} = \@variantLoop;
	$var{'variants.message'} = WebGUI::International::get('available product configurations', 'Macro_Product');
	$templateId = $_[1] || $product->get('templateId');
	
	return WebGUI::Asset::Template->new($templateId)->process(\%var);
}

1;
	

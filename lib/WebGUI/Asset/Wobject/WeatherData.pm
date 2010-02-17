package WebGUI::Asset::Wobject::WeatherData;

=head1 LEGAL 

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Weather::Com::Finder;
BEGIN {
    # This is horrible, and needs to be removed when Weather::Com > 0.5.3 is released.
    my $old_get_weather = \&Weather::Com::Base::get_weather;
    no warnings 'redefine';
    *Weather::Com::Base::get_weather = sub {
        my $self = shift;
        $self->{LINKS} = 1;
        return $self->$old_get_weather(@_);
    };
}

use WebGUI::International;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
aspect tableName => 'WeatherData';
aspect assetName => ["assetName", 'Asset_WeatherData'];
aspect icon      => 'weatherData.gif';
property partnerId => (
            fieldType   => "text",
            tab         => "properties",
            default     => undef,
            hoverHelp   => ["partnerId help", 'Asset_WeatherData'],
            label       => ["partnerId", 'Asset_WeatherData'],
            subtext     => \&_partnerId_subtext,
          );
sub _partnerId_subtext {
    my $session = shift->session;
    my $i18n    = WebGUI::International->new($session, 'Asset_WeatherData');
    return '<a href="http://www.weather.com/services/xmloap.html">'.$i18n->get("you need a weather.com key").'</a>';
}
property licenseKey => (
            fieldType   => "text",
            tab         => "properties",
            default     => undef,
            hoverHelp   => ["licenseKey help", 'Asset_WeatherData'],
            label       => ["licenseKey", 'Asset_WeatherData'],
         );
property templateId => (
            fieldType   => "template",
            tab         => "display",
            default     => 'WeatherDataTmpl0000001',
            namespace   => "WeatherData",
            hoverHelp   => ["Current Weather Conditions Template to use", 'Asset_WeatherData'],
            label       => ["Template", 'Asset_WeatherData'],
         );
property locations => (
            fieldType   => "textarea",
            default     => "Madison, WI\nToronto, Canada\n53536",
            tab         => "properties",
            hoverHelp   => ["Your list of default weather locations", 'Asset_WeatherData'],
            label       => ["Default Locations", 'Asset_WeatherData'],
         );

use WebGUI::Utility;

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->templateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->templateId,
            assetId    => $self->getId,
        );
    }
	$template->prepare($self->getMetaDataAsTemplateVariables);
	$self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style

=cut

sub view {
	my $self = shift;
	my %var;
    my $url = $self->session->url;
    
	if ($self->partnerId ne "" && $self->licenseKey ne "") {
		foreach my $location (split("\n", $self->locations)) {
		    my $weather = Weather::Com::Finder->new({
				'partner_id' => $self->partnerId, 
       	        'license'    => $self->licenseKey,
				'cache'		 => '/tmp',
				});	
			next unless defined $weather;

            foreach my $foundLocation(@{$weather->find($location)}) {
                my $current_conditions = $foundLocation->current_conditions;
                my $conditions = $current_conditions->description;
                $conditions    =~ s/\b(\w)/uc($1)/eg;
                my $tempC      = $current_conditions->temperature;
                my $tempF;
                $tempF = sprintf("%.0f",(((9/5)*$tempC) + 32)) if($tempC);
                my $icon = $current_conditions->icon || "na";

                push(@{$var{'ourLocations.loop'}}, {
                    query       => $location,
                    cityState   => $foundLocation->name || $location,
                    sky         => $conditions || 'N/A',
                    tempF       => (defined $tempF)?$tempF:'N/A',
                    tempC       => (defined $tempC)?$tempC:'N/A',
                    smallIcon   => $url->extras("wobject/WeatherData/small_icons/".$icon.".png"),
                    mediumIcon  => $url->extras("wobject/WeatherData/medium_icons/".$icon.".png"),
                    largeIcon   => $url->extras("wobject/WeatherData/large_icons/".$icon.".png"),
                    iconUrl     => $url->extras("wobject/WeatherData/medium_icons/".$icon.".png"),
                    iconAlt     => $conditions,
                });
                if (!$var{links_loop}) {
                    $var{links_loop} = [];
                    for my $lnk (@{$foundLocation->current_conditions->{WEATHER}{lnks}{link}} ) {
                        push @{$var{links_loop}}, {
                            link_url    => $lnk->{l},
                            link_title  => $lnk->{t},
                        };
                    }
                }
			}
		}
	}
	return $self->processTemplate(\%var, undef, $self->{_viewTemplate});
}

1;

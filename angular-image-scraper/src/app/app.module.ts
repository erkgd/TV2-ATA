import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule, HTTP_INTERCEPTORS, HttpClientXsrfModule } from '@angular/common/http';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { HeaderComponent } from './components/header/header.component';
import { FooterComponent } from './components/footer/footer.component';
import { HomeComponent } from './components/home/home.component';
import { ImageDetailComponent } from './components/image-detail/image-detail.component';
import { LoginComponent } from './components/auth/login.component';
import { RegisterComponent } from './components/auth/register.component';
import { ProfileComponent } from './components/profile/profile.component';
import { AdvancedSearchComponent } from './components/search/advanced-search.component';
import { AuthInterceptor } from './interceptors/auth.interceptor';
import { CsrfInterceptor } from './interceptors/csrf.interceptor';

// Services
import { AuthService } from './services/auth.service';
import { ImageService } from './services/image.service';
import { SearchService } from './services/search.service';

@NgModule({
  declarations: [
    AppComponent,
    HeaderComponent,
    FooterComponent,
    HomeComponent,
    ImageDetailComponent,
    LoginComponent,
    RegisterComponent,
    ProfileComponent,
    AdvancedSearchComponent
  ],  imports: [
    BrowserModule,
    AppRoutingModule,
    FormsModule,
    ReactiveFormsModule,
    HttpClientModule,
    HttpClientXsrfModule.withOptions({
      cookieName: 'csrftoken',
      headerName: 'X-CSRFToken'
    })
  ],
  providers: [
    AuthService,
    ImageService,
    SearchService,
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: CsrfInterceptor,
      multi: true
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: CsrfInterceptor,
      multi: true
    }
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }

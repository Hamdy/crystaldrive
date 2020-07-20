<template *ngIf="this.$route.query.signedAttempt">
  <div id="login" :class="{ recaptcha: recaptcha }">
    <form @submit="submit">
      <img :src="logoURL" alt="File Browser">
      <h1>{{ name }}</h1>
      <div v-if="error !== ''" class="wrong">{{ error }}</div>

      <input class="button button--block" type="submit" value="Login/Signup with 3bot">

    </form>
  </div>
</template>

<script>
import * as auth from '@/utils/auth'
import { name, logoURL, recaptcha, signup } from '@/utils/constants'



export default {
  name: 'login',
  computed: {
    signup: () => signup,
    name: () => name,
    logoURL: () => logoURL
  },
  data: function () {
    return {
      createMode: false,
      error: '',
      username: '',
      password: '',
      recaptcha: recaptcha,
      passwordConfirm: ''
    }
  },
  async mounted () {
    let redirect = this.$route.query.redirect
    
    if (redirect === '' || redirect === undefined || redirect === null) {
          redirect = '/files/'
    }

    let signedAttempt = this.$route.query.signedAttempt
    
    // means coming back from 3botlogin,we need to validate coming query params
    // get token for user and set token
    if (signedAttempt){
      try{
        await auth.threebotLogin(this.$route.query)
        window.location.href = redirect
      }catch (e){
          this.error = e
      }
    }
  },
  methods: {
    toggleMode () {
      this.createMode = !this.createMode
    },
    async submit (event) {
      event.preventDefault()
      event.stopPropagation()

      let redirect = this.$route.query.redirect
      if (redirect === '' || redirect === undefined || redirect === null) {
        redirect = '/files/'
      }

      let captcha = ''
      if (recaptcha) {
        captcha = window.grecaptcha.getResponse()

        if (captcha === '') {
          this.error = this.$t('login.wrongCredentials')
          return
        }
      }

      if (this.createMode) {
        if (this.password !== this.passwordConfirm) {
          this.error = this.$t('login.passwordsDontMatch')
          return
        }
      }

      try {
        if (this.createMode) {
          await auth.signup(this.username, this.password)
        }
        await auth.login(redirect)
      } catch (e) {
          this.error = "Error redirecting user to 3bot login"
      }
    }
  }
}
</script>
